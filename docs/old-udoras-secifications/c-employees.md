# Customer - Employees List Wireframe

![Customer - Employees List](./c-employees.png)

## Image Preview

![Customer - Employees List](./c-employees.png)

## ASCII Representation

```
+------------------------------------------------------+
|  +------+   +-----------+   +----------------+   +-+ |
|  | Logo |   | Employees |   | Training req.  |   |U| |
|  +------+   +-----------+   +----------------+   +-+ |
|                                                      |
|  +------------------------------------------+  +-+   |
|  |                Search                    |  |S|   |
|  +------------------------------------------+  +-+   |
|                                                      |
|  +----------+----------------+----------------+      |
|  | Employee | Email          | Phone Number   |      |
|  +----------+----------------+----------------+      |
|  | FirstName| name@company   | +44123123544   |      |
|  | LastName | .com           |                |      |
|  +----------+----------------+----------------+      |
|  | FirstName| name@company   | +74123123544   |      |
|  | LastName | .com           |                |      |
|  +----------+----------------+----------------+      |
|  | FirstName| name@company   | +14123123545   |      |
|  | LastName | .com           |                |      |
|  +----------+----------------+----------------+      |
|  | FirstName| name@company   | +14123113544   |      |
|  | LastName | .com           |                |      |
|  +----------+----------------+----------------+      |
|                                                      |
|  « | 1 | 2 | 3 | 4 | 5 | »                           |
|                                                      |
| Privacy Policy                                       |
+------------------------------------------------------+
```

## Overview

This wireframe displays the "Employees" interface from the customer perspective. It shows a list of all employees within the customer's organization, allowing for management and access to employee information and certificates.

## UI Components

### Navigation Header
- **Logo**: Organization or application logo in the top-left corner
- **Main Navigation**: Horizontal menu with options for Employees (currently selected) and Training requests
- **User Profile**: Icon in the top-right corner for accessing user account options
- **Navigation Arrow**: Button in the top-right corner for additional navigation options

### Action Controls
- **Search Bar**: Full-width search field at the top of the content area
- **Search Button**: Button to execute the search query
- **Create Employee Button**: Button to add a new employee to the organization

### Employees Table
- **Table Headers**:
  - Employee: Name of the employee
  - Email: Email address of the employee
  - Phone Number: Contact phone number
  - Actions: Available operations for each employee

- **Table Rows**: Multiple entries showing employee information with the following columns:
  - Employee Name (formatted as FirstName SecondName)
  - Email Address (formatted as name@company.com)
  - Phone Number (with international format, e.g., +44123123544)
  - Action status/button: Either "Certificates" button or "No Certificates yet." text

### Pagination Controls
- **Page Navigation**: Controls at the bottom of the table with first («), previous, numbered pages (1-5), next, and last (») buttons
- **Current Page**: Page 1 is currently selected

### Additional Information
- **Privacy Policy**: Link at the bottom-left of the page
- **Note**: Yellow sticky note with important information: "When Vendor gets a link to the training and opens it, Training page should open. Click here to see the Training page"

## Functionality

This interface allows customers to:

1. **Browse Employees**: View all employees in their organization in a paginated table format
2. **Search for Employees**: Find specific employees using the search functionality
3. **Create New Employees**: Add new employee accounts via the "Create Employee" button
4. **Access Employee Certificates**: View certificates for employees who have completed trainings
5. **Navigate**: Move between different pages of employees if the organization has many employees

## Notes

- The interface provides a comprehensive view of all employees within the customer's organization
- Some employees have earned certificates (indicated by the "Certificates" button), while others have not yet completed any trainings (indicated by "No Certificates yet.")
- The sticky note suggests that vendors can access training directly through links, which will open the training page
- Phone numbers are shown with international dialing codes, suggesting a global user base
- The "Create Employee" button indicates that customers can add new employees directly from this interface
- The system maintains a consistent layout with other list views in the application
- This screen serves as a central hub for managing employees and their training progress
