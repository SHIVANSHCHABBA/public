# Time Complexity Analysis with Pseudo-code

## Data Structures

### 1. Custom Hash Table
Used for O(1) average time access to resources by ID.

#### Implementation Details:
```pseudocode
class HashNode:
    Key
    Value
    Next pointer

class CustomHashTable:
    Array of HashNodes (buckets)
    Size
    Capacity (default = 16)
    Load factor = 0.75
```

#### Operations:
```pseudocode
PUT(key, value):
    index = hash(key) % capacity
    if bucket[index] exists:
        traverse linked list to find/update key
        or add to front if not found
    else:
        create new node at bucket[index]
    if size/capacity > 0.75:
        resize()
Time Complexity: O(1) average, O(n) worst case
Space Complexity: O(n)

GET(key):
    index = hash(key) % capacity
    traverse bucket[index] linked list
    return value if found, null if not
Time Complexity: O(1) average, O(n) worst case
```

### 2. Custom Binary Search Tree
Used for efficient searching by string fields (title, author, genre).

#### Implementation Details:
```pseudocode
class TreeNode:
    Data (key)
    List<LibraryResource>
    Left pointer
    Right pointer
```

#### Operations:
```pseudocode
INSERT(key, resource):
    if root is null:
        create new node with key
        add resource to node's list
    else:
        traverse tree comparing keys
        insert at appropriate position
Time Complexity: O(log n) average, O(n) worst case
Space Complexity: O(n)

SEARCH(key):
    traverse tree comparing keys
    return matching node's resource list
Time Complexity: O(log n) average, O(n) worst case

SEARCH_BY_PREFIX(prefix):
    results = empty list
    traverse entire tree:
        if node.key starts with prefix:
            add node's resources to results
    return results
Time Complexity: O(n)
```

## Core Operations

### 1. Resource Management

#### Add Resource:
```pseudocode
ADD_RESOURCE(resource):
    validate resource
    add to database
    add to hash table cache
    add to title index BST
    add to author index BST
    add to genre index BST
Time Complexity: O(1) for DB + O(log n) for indexes
```

#### Update Resource:
```pseudocode
UPDATE_RESOURCE(resource):
    validate resource
    update in database
    update in hash table cache
Time Complexity: O(1) average
```

#### Remove Resource:
```pseudocode
REMOVE_RESOURCE(id):
    check if resource exists
    check if currently borrowed
    remove from database
Time Complexity: O(1)
```

### 2. Search Operations

#### Search by ID:
```pseudocode
GET_BY_ID(id):
    check cache hash table
    if not found:
        query database
        update cache
Time Complexity: O(1) average
```

#### Search by Title/Author/Genre:
```pseudocode
SEARCH_BY_FIELD(field, value):
    if field is empty:
        return empty list
    get matching BST index
    return search results
Time Complexity: O(log n) average
```

### 3. Borrowing Operations

#### Borrow Resource:
```pseudocode
BORROW_RESOURCE(resourceId, borrowerName, loanPeriod):
    get resource
    if not available:
        return error
    create borrowing record
    update resource availability
    save changes
Time Complexity: O(1)
```

#### Return Resource:
```pseudocode
RETURN_RESOURCE(resourceId):
    find active borrowing record
    if not found:
        return error
    update return date
    update resource availability
    save changes
Time Complexity: O(1)
```

### 4. Report Operations

#### Get Overdue Items:
```pseudocode
GET_OVERDUE_ITEMS():
    query database for:
        return_date is null AND
        due_date < current_date
    order by due_date
Time Complexity: O(n)
```

#### Get Resources by Category:
```pseudocode
GET_RESOURCES_BY_CATEGORY():
    get all resources
    group by genre
    count items in each group
Time Complexity: O(n)
```

## Space Complexity Analysis

### Data Structure Storage:
- Hash Table: O(n) where n is number of resources
- Binary Search Trees: O(n) per tree
- Database: O(n) for resources + O(m) for borrowing records

### Runtime Memory:
- Cache: O(n) for resource cache
- Search Operations: O(k) where k is size of result set
- Report Generation: O(n) for loading data

## Performance Optimization Techniques

1. Caching:
   - Resource cache using hash table
   - Indexes using BST for string-based searches

2. Lazy Loading:
   - Load data into indexes only when needed
   - Cache results of expensive operations

3. Database Optimization:
   - Proper indexing on frequently queried fields
   - Use of foreign keys for referential integrity

## Scalability Considerations

1. Memory Usage:
   - Cache size grows linearly with resource count
   - Consider implementing LRU cache for very large datasets

2. Search Performance:
   - BST may degrade to O(n) if unbalanced
   - Consider using AVL or Red-Black trees for guaranteed O(log n)

3. Database Performance:
   - Use pagination for large result sets
   - Implement query optimization for complex reports