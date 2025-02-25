# Users - Employees List Wireframe

![Users - Employees List](./a-users-employees.png)

## ASCII Representation

```
+--------------------------------------------------------------------------------------------------------------+
|                                                                                                              |
| +--------+  +--------+  +--------+  +--------+  +--------+  +--------+                    +--------+         |
| |        |  |        |  |        |  |        |  |        |  |        |                    |        |         |
| |  Logo  |  | Users  |  |Trainings|  |Payments|  |Certificates|  | Reports |                    |   →    |         |
| |        |  |        |  |        |  |        |  |        |  |        |                    |        |         |
| +--------+  +--------+  +--------+  +--------+  +--------+  +--------+                    +--------+         |
|                                                                                                              |
| +---------------+  +---------------+  +---------------+                                  +---------------+    |
| |   Customers   |  |    Vendors    |  |   Employees   |                                  | Create Employee|    |
| +---------------+  +---------------+  +---------------+                                  +---------------+    |
|                                                                                                              |
| +------------------------------------------------------------------+  +--------+                             |
| |                                                                  |  | Search |                             |
| +------------------------------------------------------------------+  +--------+                             |
|                                                                                                              |
| +------------------+------------------+------------------+------------------+---------------+                |
| |     Employee     |      Vendor      |       Email      |   Phone Number   |    Actions    |                |
| +------------------+------------------+------------------+------------------+---------------+                |
| |                  |                  |                  |                  |               |                |
| | FirstName        | Vendor Name      | name@company.com | +44123123544     | Delete        |                |
| | SecondName       |                  |                  |                  |               |                |
| +------------------+------------------+------------------+------------------+---------------+                |
| |                  |                  |                  |                  |               |                |
| | FirstName        |                  | name@company.com | +74123123544     | Delete        |                |
| | SecondName       |                  |                  |                  |               |                |
| +------------------+------------------+------------------+------------------+---------------+                |
| |                  |                  |                  |                  |               |                |
| | FirstName        | Vendor Name      | name@company.com | +14123123545     | Delete        |                |
| | SecondName       |                  |                  |                  |               |                |
| +------------------+------------------+------------------+------------------+---------------+                |
| |                  |                  |                  |                  |               |                |
| | FirstName        |                  | name@company.com | +14123113544     | Delete        |                |
| | SecondName       |                  |                  |                  |               |                |
| +------------------+------------------+------------------+------------------+---------------+                |
| |                  |                  |                  |                  |               |                |
| | FirstName        | Vendor Name      | name@company.com | +44199923544     | Delete        |                |
| | SecondName       |                  |                  |                  |               |                |
| +------------------+------------------+------------------+------------------+---------------+                |
| |                  |                  |                  |                  |               |                |
| | FirstName        | Vendor Name      | name@company.com | +12345123544     | Delete        |                |
| | SecondName       |                  |                  |                  |               |                |
| +------------------+------------------+------------------+------------------+---------------+                |
|                                                                                                              |
| Privacy Policy           « | 1 | 2 | 3 | 4 | 5 | »                                                           |
|                                                                                                              |
+--------------------------------------------------------------------------------------------------------------+
```

## Overview

This wireframe displays the "Users - Employees" interface, which shows a list of all employee accounts in the system. The interface presents a tabular view of employee information with filtering, creation, and deletion capabilities.

## UI Components

### Navigation Header
- **Logo**: Organization or application logo in the top-left corner
- **Main Navigation**: Horizontal menu with options for Users (currently selected), Trainings, Payments, Certificates, and Reports
- **Navigation Arrow**: Button in the top-right corner for additional navigation options or to collapse/expand the menu

### User Type Tabs
- **Customers Tab**: Tab to switch to customer accounts view
- **Vendors Tab**: Tab to switch to vendor accounts view
- **Employees Tab**: Currently selected tab showing employee accounts

### Action Controls
- **Search Bar**: Full-width search field at the top of the content area
- **Search Button**: Button to execute the search query
- **Create Employee Button**: Button to create a new employee account

### Employees Table
- **Table Headers**:
  - Employee: Name of the employee
  - Vendor: Name of the vendor associated with the employee
  - Email: Email address of the employee
  - Phone Number: Contact phone number
  - Actions: Available operations for each employee account

- **Table Rows**: Multiple entries showing employee information with the following columns:
  - Employee Name (formatted as FirstName SecondName)
  - Vendor Name (may be empty for some employees)
  - Email Address (formatted as name@company.com)
  - Phone Number (with international format, e.g., +44123123544)
  - Action button: "Delete" for removing the employee account

### Pagination Controls
- **Page Navigation**: Controls at the bottom of the table with first («), previous, numbered pages (1-5), next, and last (») buttons
- **Current Page**: Page 1 is currently selected

### Additional Information
- **Privacy Policy**: Link at the bottom-left of the page

## Functionality

This interface allows administrators to:

1. **Browse Employee Accounts**: View all employee accounts in a paginated table format
2. **Search for Employees**: Find specific employees using the search functionality
3. **Create New Employees**: Add new employee accounts via the "Create Employee" button
4. **Delete Employees**: Remove employee accounts that are no longer needed
5. **Navigate Between User Types**: Switch between different user categories (Customers, Vendors, Employees)
6. **Paginate Results**: Move between different pages of employee accounts
7. **View Vendor Associations**: See which vendor each employee is associated with

## Notes

- The interface uses a tab-based navigation to separate different user types (Customers, Vendors, Employees)
- Employee names are displayed in a "FirstName SecondName" format
- Some employees do not have an associated vendor (empty vendor field)
- Phone numbers are shown with international dialing codes, suggesting a global user base
- The "Delete" action suggests that administrators have the authority to remove employee accounts
- The "Create Employee" button indicates that new employee accounts can be added directly from this interface
- The system maintains a consistent layout with other list views in the application, providing a familiar user experience
- The table appears to show all essential employee information at a glance, facilitating quick identification and management
