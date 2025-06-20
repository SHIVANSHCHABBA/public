IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'LibraryManagementDB')
BEGIN
    CREATE DATABASE LibraryManagementDB;
END
GO

USE LibraryManagementDB;
GO

-- ========================================
-- DROP EXISTING TABLES (for clean setup)
-- ========================================
IF OBJECT_ID('dbo.BorrowingRecords', 'U') IS NOT NULL
    DROP TABLE dbo.BorrowingRecords;
GO

IF OBJECT_ID('dbo.Resources', 'U') IS NOT NULL
    DROP TABLE dbo.Resources;
GO

-- ========================================
-- CREATE TABLES
-- ========================================

-- Table: Resources (LibraryResource in C#)
CREATE TABLE dbo.Resources (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Title NVARCHAR(200) NOT NULL,
    Author NVARCHAR(100) NOT NULL,
    PublicationYear INT NOT NULL,
    Genre NVARCHAR(50) NOT NULL,
    IsAvailable BIT NOT NULL DEFAULT 1,
    Type INT NOT NULL,
    CreatedDate DATETIME2 DEFAULT GETDATE(),
    LastModified DATETIME2 DEFAULT GETDATE()
);
GO

-- Table: BorrowingRecords
CREATE TABLE dbo.BorrowingRecords (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    ResourceId INT NOT NULL,
    BorrowerName NVARCHAR(100) NOT NULL,
    BorrowDate DATETIME2 NOT NULL DEFAULT GETDATE(),
    DueDate DATETIME2 NOT NULL,
    ReturnDate DATETIME2 NULL,
    CreatedDate DATETIME2 DEFAULT GETDATE(),
    LastModified DATETIME2 DEFAULT GETDATE(),
    
    -- Foreign Key Constraint
    CONSTRAINT FK_BorrowingRecords_Resources 
        FOREIGN KEY (ResourceId) REFERENCES dbo.Resources(Id)
        ON DELETE CASCADE
);
GO

-- ========================================
-- CREATE INDEXES FOR PERFORMANCE
-- ========================================

-- Index on Resources for efficient searching
CREATE NONCLUSTERED INDEX IX_Resources_Title 
    ON dbo.Resources (Title);
GO

CREATE NONCLUSTERED INDEX IX_Resources_Author 
    ON dbo.Resources (Author);
GO

CREATE NONCLUSTERED INDEX IX_Resources_Genre 
    ON dbo.Resources (Genre);
GO

CREATE NONCLUSTERED INDEX IX_Resources_PublicationYear 
    ON dbo.Resources (PublicationYear);
GO

CREATE NONCLUSTERED INDEX IX_Resources_IsAvailable 
    ON dbo.Resources (IsAvailable);
GO

-- Index on BorrowingRecords for efficient queries
CREATE NONCLUSTERED INDEX IX_BorrowingRecords_ResourceId 
    ON dbo.BorrowingRecords (ResourceId);
GO

CREATE NONCLUSTERED INDEX IX_BorrowingRecords_DueDate 
    ON dbo.BorrowingRecords (DueDate);
GO

CREATE NONCLUSTERED INDEX IX_BorrowingRecords_ReturnDate 
    ON dbo.BorrowingRecords (ReturnDate);
GO

CREATE NONCLUSTERED INDEX IX_BorrowingRecords_BorrowerName 
    ON dbo.BorrowingRecords (BorrowerName);
GO

-- ========================================
-- CREATE CHECK CONSTRAINTS
-- ========================================

-- Constraint: Publication Year should be reasonable
ALTER TABLE dbo.Resources 
ADD CONSTRAINT CK_Resources_PublicationYear 
    CHECK (PublicationYear >= 1000 AND PublicationYear <= YEAR(GETDATE()));
GO

-- Constraint: Resource Type should be valid (1=Book, 2=Journal, 3=Media)
ALTER TABLE dbo.Resources 
ADD CONSTRAINT CK_Resources_Type 
    CHECK (Type IN (1, 2, 3));
GO

-- Constraint: Title should not be empty
ALTER TABLE dbo.Resources 
ADD CONSTRAINT CK_Resources_Title 
    CHECK (LEN(LTRIM(RTRIM(Title))) > 0);
GO

-- Constraint: Author should not be empty
ALTER TABLE dbo.Resources 
ADD CONSTRAINT CK_Resources_Author 
    CHECK (LEN(LTRIM(RTRIM(Author))) > 0);
GO

-- Constraint: Genre should not be empty
ALTER TABLE dbo.Resources 
ADD CONSTRAINT CK_Resources_Genre 
    CHECK (LEN(LTRIM(RTRIM(Genre))) > 0);
GO

-- Constraint: Borrower Name should not be empty
ALTER TABLE dbo.BorrowingRecords 
ADD CONSTRAINT CK_BorrowingRecords_BorrowerName 
    CHECK (LEN(LTRIM(RTRIM(BorrowerName))) > 0);
GO

-- Constraint: Due Date should be after Borrow Date
ALTER TABLE dbo.BorrowingRecords 
ADD CONSTRAINT CK_BorrowingRecords_DueDate 
    CHECK (DueDate > BorrowDate);
GO

-- Constraint: Return Date should be after Borrow Date (if not null)
ALTER TABLE dbo.BorrowingRecords 
ADD CONSTRAINT CK_BorrowingRecords_ReturnDate 
    CHECK (ReturnDate IS NULL OR ReturnDate >= BorrowDate);
GO

-- ========================================
-- CREATE TRIGGERS FOR AUDIT TRAIL
-- ========================================

-- Trigger: Update LastModified on Resources
CREATE TRIGGER TR_Resources_UpdateLastModified
ON dbo.Resources
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    UPDATE dbo.Resources 
    SET LastModified = GETDATE()
    FROM dbo.Resources r
    INNER JOIN inserted i ON r.Id = i.Id;
END
GO

-- Trigger: Update LastModified on BorrowingRecords
CREATE TRIGGER TR_BorrowingRecords_UpdateLastModified
ON dbo.BorrowingRecords
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    UPDATE dbo.BorrowingRecords 
    SET LastModified = GETDATE()
    FROM dbo.BorrowingRecords br
    INNER JOIN inserted i ON br.Id = i.Id;
END
GO

-- ========================================
-- CREATE VIEWS FOR COMMON QUERIES
-- ========================================

-- View: Available Resources
CREATE VIEW vw_AvailableResources AS
SELECT 
    Id,
    Title,
    Author,
    PublicationYear,
    Genre,
    CASE Type 
        WHEN 1 THEN 'Book'
        WHEN 2 THEN 'Journal'
        WHEN 3 THEN 'Media'
        ELSE 'Unknown'
    END AS ResourceType,
    CreatedDate
FROM dbo.Resources
WHERE IsAvailable = 1;
GO

-- View: Currently Borrowed Resources
CREATE VIEW vw_CurrentlyBorrowedResources AS
SELECT 
    r.Id,
    r.Title,
    r.Author,
    r.Genre,
    br.BorrowerName,
    br.BorrowDate,
    br.DueDate,
    DATEDIFF(DAY, br.DueDate, GETDATE()) AS DaysOverdue,
    CASE 
        WHEN br.DueDate < GETDATE() THEN 'Overdue'
        ELSE 'On Time'
    END AS Status
FROM dbo.Resources r
INNER JOIN dbo.BorrowingRecords br ON r.Id = br.ResourceId
WHERE br.ReturnDate IS NULL;
GO

-- View: Overdue Resources
CREATE VIEW vw_OverdueResources AS
SELECT 
    r.Id,
    r.Title,
    r.Author,
    br.BorrowerName,
    br.BorrowDate,
    br.DueDate,
    DATEDIFF(DAY, br.DueDate, GETDATE()) AS DaysOverdue
FROM dbo.Resources r
INNER JOIN dbo.BorrowingRecords br ON r.Id = br.ResourceId
WHERE br.ReturnDate IS NULL 
    AND br.DueDate < GETDATE();
GO

-- View: Resource Statistics by Genre
CREATE VIEW vw_ResourceStatsByGenre AS
SELECT 
    Genre,
    COUNT(*) AS TotalResources,
    SUM(CASE WHEN IsAvailable = 1 THEN 1 ELSE 0 END) AS AvailableResources,
    SUM(CASE WHEN IsAvailable = 0 THEN 1 ELSE 0 END) AS BorrowedResources,
    CAST(SUM(CASE WHEN IsAvailable = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS DECIMAL(5,2)) AS AvailabilityPercentage
FROM dbo.Resources
GROUP BY Genre;
GO

-- ========================================
-- CREATE STORED PROCEDURES
-- ========================================

-- Procedure: Get Resource Details with Borrowing History
CREATE PROCEDURE sp_GetResourceWithHistory
    @ResourceId INT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Resource Details
    SELECT 
        Id,
        Title,
        Author,
        PublicationYear,
        Genre,
        IsAvailable,
        CASE Type 
            WHEN 1 THEN 'Book'
            WHEN 2 THEN 'Journal'
            WHEN 3 THEN 'Media'
            ELSE 'Unknown'
        END AS ResourceType,
        CreatedDate,
        LastModified
    FROM dbo.Resources
    WHERE Id = @ResourceId;
    
    -- Borrowing History
    SELECT 
        Id,
        BorrowerName,
        BorrowDate,
        DueDate,
        ReturnDate,
        CASE 
            WHEN ReturnDate IS NULL AND DueDate < GETDATE() THEN 'Overdue'
            WHEN ReturnDate IS NULL THEN 'Current'
            WHEN ReturnDate > DueDate THEN 'Returned Late'
            ELSE 'Returned On Time'
        END AS Status,
        CASE 
            WHEN ReturnDate IS NULL THEN DATEDIFF(DAY, BorrowDate, GETDATE())
            ELSE DATEDIFF(DAY, BorrowDate, ReturnDate)
        END AS LoanDuration
    FROM dbo.BorrowingRecords
    WHERE ResourceId = @ResourceId
    ORDER BY BorrowDate DESC;
END
GO

-- Procedure: Search Resources by Multiple Criteria
CREATE PROCEDURE sp_SearchResources
    @Title NVARCHAR(200) = NULL,
    @Author NVARCHAR(100) = NULL,
    @Genre NVARCHAR(50) = NULL,
    @PublicationYear INT = NULL,
    @IsAvailable BIT = NULL,
    @ResourceType INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        Id,
        Title,
        Author,
        PublicationYear,
        Genre,
        IsAvailable,
        CASE Type 
            WHEN 1 THEN 'Book'
            WHEN 2 THEN 'Journal'
            WHEN 3 THEN 'Media'
            ELSE 'Unknown'
        END AS ResourceType
    FROM dbo.Resources
    WHERE 
        (@Title IS NULL OR Title LIKE '%' + @Title + '%')
        AND (@Author IS NULL OR Author LIKE '%' + @Author + '%')
        AND (@Genre IS NULL OR Genre LIKE '%' + @Genre + '%')
        AND (@PublicationYear IS NULL OR PublicationYear = @PublicationYear)
        AND (@IsAvailable IS NULL OR IsAvailable = @IsAvailable)
        AND (@ResourceType IS NULL OR Type = @ResourceType)
    ORDER BY Title, Author;
END
GO

-- Procedure: Generate Borrowing Report
CREATE PROCEDURE sp_GenerateBorrowingReport
    @StartDate DATETIME2 = NULL,
    @EndDate DATETIME2 = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    IF @StartDate IS NULL SET @StartDate = DATEADD(MONTH, -1, GETDATE());
    IF @EndDate IS NULL SET @EndDate = GETDATE();
    
    SELECT 
        r.Title,
        r.Author,
        r.Genre,
        br.BorrowerName,
        br.BorrowDate,
        br.DueDate,
        br.ReturnDate,
        CASE 
            WHEN br.ReturnDate IS NULL AND br.DueDate < GETDATE() THEN 'Overdue'
            WHEN br.ReturnDate IS NULL THEN 'Current'
            WHEN br.ReturnDate > br.DueDate THEN 'Returned Late'
            ELSE 'Returned On Time'
        END AS Status,
        CASE 
            WHEN br.ReturnDate IS NULL THEN DATEDIFF(DAY, br.BorrowDate, GETDATE())
            ELSE DATEDIFF(DAY, br.BorrowDate, br.ReturnDate)
        END AS LoanDuration
    FROM dbo.BorrowingRecords br
    INNER JOIN dbo.Resources r ON br.ResourceId = r.Id
    WHERE br.BorrowDate BETWEEN @StartDate AND @EndDate
    ORDER BY br.BorrowDate DESC;
END
GO
