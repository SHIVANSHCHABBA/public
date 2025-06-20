 Library Management System

A comprehensive console-based library management system built with C and Entity Framework Core, featuring custom data structures for optimized performance.

 Features

 Core Functionality
- Resource Management: Add, update, remove, and search library resources (books, journals, media)
- Borrowing System: Borrow and return resources with due date tracking
- Search Capabilities: Search by title, author, or genre with prefix matching
- Reporting: Overdue items report and resources by category statistics
- Data Validation: Comprehensive input validation and error handling

 Performance Optimizations
- Custom Hash Table: O(1) average-case resource lookup by ID
- Binary Search Tree Indexes: O(log n) searches by title, author, and genre
- In-Memory Caching: Fast access to frequently accessed resources
- Efficient Database Operations: Entity Framework Core with SQL Server LocalDB

 Technical Architecture

 Entity Models
- LibraryResource: Core entity representing books, journals, and media
- BorrowingRecord: Tracks borrowing history and current loans
- ResourceType: Enum for different resource categories

 Custom Data Structures

 Custom Hash Table
```csharp
// O(1) average case insertion and retrieval
CustomHashTable<int, LibraryResource> resourceCache
```
- Handles collisions using chaining
- Automatic resizing when load factor exceeds 0.75
- Optimized for resource ID lookups

 Binary Search Tree
```csharp
// O(log n) sorted searches with prefix matching
CustomBinarySearchTree<string> titleIndex
```
- Maintains sorted indexes for titles, authors, and genres
- Supports exact matches and prefix searches
- Self-organizing structure for efficient queries

 Time Complexity Analysis

| Operation | Average Case | Worst Case |
|-----------|--------------|------------|
| Add Resource | O(1) + O(log n) | O(n) |
| Search by ID | O(1) | O(n) |
| Search by Title/Author/Genre | O(log n) | O(n) |
| Update Resource | O(1) | O(n) |
| Borrow/Return | O(1) | O(1) |

 Prerequisites

- .NET 6.0 or later
- SQL Server LocalDB
- Entity Framework Core 6.0+

 Installation

1. Clone the repository
   ```bash
   git clone <repository-url>
   cd LibraryManagementSystem
   ```

2. Install dependencies
   ```bash
   dotnet restore
   ```

3. Configure database
   - The application uses SQL Server LocalDB by default
   - Database is automatically created on first run
   - Connection string: `Server=(localdb)\\mssqllocaldb;Database=LibraryManagementDB;Trusted_Connection=true;`

4. Build and run
   ```bash
   dotnet build
   dotnet run
   ```

 Usage

 Main Menu Options

1. Add Resource - Add new books, journals, or media to the library
2. Update Resource - Modify existing resource information
3. Remove Resource - Delete resources (only if not currently borrowed)
4. Search by Title - Find resources using title keywords
5. Search by Author - Find resources by author name
6. Search by Genre - Find resources in specific categories
7. View All Resources - Display complete library inventory
8. Borrow Resource - Check out resources to borrowers
9. Return Resource - Process resource returns
10. Show Overdue Items - Generate overdue items report
11. Show Resources by Category - View library statistics by genre
12. Exit - Close the application

 Example Usage

 Adding a Resource
```
Enter Title: Advanced C Programming
Enter Author/Creator: John Doe
Enter Publication Year: 2023
Enter Genre/Category: Programming
Select Resource Type: 1 (Book)
```

 Searching for Resources
```
Search by Title: "advanced"
Results: All resources with titles containing "advanced"

Search by Author: "doe"
Results: All resources by authors with "doe" in their name
```

 Borrowing a Resource
```
Enter Resource ID: 1
Enter Borrower Name: Jane Smith
Enter loan period: 14 days
Due Date: 2024-01-15
```

 Database Schema

 LibraryResource Table
- `Id` (Primary Key)
- `Title` (Required, Max 200 chars)
- `Author` (Required, Max 100 chars)
- `PublicationYear` (Range: 1000-current year)
- `Genre` (Required, Max 50 chars)
- `IsAvailable` (Boolean, default: true)
- `Type` (Enum: Book=1, Journal=2, Media=3)

 BorrowingRecord Table
- `Id` (Primary Key)
- `ResourceId` (Foreign Key)
- `BorrowerName` (Required, Max 100 chars)
- `BorrowDate` (DateTime)
- `DueDate` (DateTime)
- `ReturnDate` (DateTime, nullable)

 Testing

The application includes comprehensive unit tests for:
- Custom hash table operations
- Binary search tree functionality
- Resource validation logic
- Library service operations

Run tests automatically on startup or manually through the test suite.

 Performance Characteristics

 Memory Usage
- Hash table: O(n) space complexity
- BST indexes: O(n) space complexity per index
- Database caching: Configurable based on usage patterns

 Scalability
- Handles thousands of resources efficiently
- Automatic hash table resizing prevents performance degradation
- Database indexing supports large datasets

 Error Handling

- Comprehensive validation for all user inputs
- Database transaction management
- Graceful error recovery with user-friendly messages
- Logging of critical operations and errors

 Configuration

 Database Connection
Modify the connection string in `LibraryContext.OnConfiguring()`:
```csharp
optionsBuilder.UseSqlServer("your-connection-string");
```

 Default Settings
- Default loan period: 14 days
- Hash table initial capacity: 16
- Automatic database creation: Enabled

 Contributing

1. Fork the repository
2. Create a feature branch
3. Implement changes with tests
4. Submit a pull request

 License

This project is open source and available under the MIT License.

 Future Enhancements

- Web-based user interface
- Multi-user support with authentication
- Advanced reporting and analytics
- Integration with external library systems
- Mobile application support
- Barcode scanning capabilities

 Support

For questions or issues, please create an issue in the repository or contact the development team.

---

Built with C and Entity Framework Core for optimal performance and maintainability.