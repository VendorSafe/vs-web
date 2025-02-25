# Udora System Mermaid Diagrams

This document contains various mermaid diagrams that visualize the structure and flow of the Udora system.

## 1. Site Map Overview

```mermaid
graph TD
    %% Main user roles
    Guest([Guest])
    Admin([Admin])
    Customer([Customer])
    Vendor([Vendor])
    Employee([Employee])
    
    %% Guest flow
    Guest --> Login
    Login --> Registration
    Registration --> EmployeeReg[Employee Registration]
    Registration --> VendorReg[Vendor Registration]
    
    %% Admin flow
    Admin --> AdminDashboard[Dashboard]
    AdminDashboard --> AdminCustomers[Customers]
    AdminDashboard --> AdminVendors[Vendors]
    AdminDashboard --> AdminEmployees[Employees]
    AdminDashboard --> AdminTrainings[Trainings]
    AdminDashboard --> AdminPayments[Payments History]
    AdminDashboard --> AdminReports[Reports]
    
    %% Customer flow
    Customer --> CustomerDashboard[Dashboard]
    CustomerDashboard --> CustomerProfile[My Profile]
    CustomerDashboard --> CustomerVendors[Vendors]
    CustomerDashboard --> CustomerEmployees[Employees]
    CustomerDashboard --> CustomerTrainings[Training List]
    
    %% Vendor flow
    Vendor --> VendorDashboard[Dashboard]
    VendorDashboard --> VendorProfile[My Profile]
    VendorDashboard --> VendorEmployees[Employees]
    VendorDashboard --> VendorTrainingRequests[Training Requests]
    VendorDashboard --> VendorTrainingInfo[Training Info]
    VendorDashboard --> VendorCertificates[Certificates]
    
    %% Employee flow
    Employee --> EmployeeDashboard[Dashboard]
    EmployeeDashboard --> EmployeeCertificates[Certificates]
    EmployeeDashboard --> EmployeeTrainingRequests[Training Requests]
    EmployeeDashboard --> EmployeeTrainingInfo[Training Info]
    
    %% Style definitions
    classDef userRole fill:#f9f,stroke:#333,stroke-width:2px;
    classDef dashboard fill:#bbf,stroke:#333,stroke-width:1px;
    
    %% Apply styles
    class Guest,Admin,Customer,Vendor,Employee userRole;
    class AdminDashboard,CustomerDashboard,VendorDashboard,EmployeeDashboard dashboard;
```

## 2. Admin User Journey

```mermaid
graph TD
    Admin([Admin]) --> AdminDashboard[Dashboard]
    
    %% Customers management
    AdminDashboard --> Customers[Customers]
    Customers --> CreateCustomer[Create Customer]
    Customers --> EditCustomer[Edit Customer]
    Customers --> DeleteCustomer[Delete Customer]
    
    %% Vendors management
    AdminDashboard --> Vendors[Vendors]
    Vendors --> CreateVendor[Create Vendor]
    Vendors --> EditVendor[Edit Vendor]
    Vendors --> DeleteVendor[Delete Vendor]
    
    %% Employees management
    AdminDashboard --> Employees[Employees]
    Employees --> CreateEmployee[Create Employee]
    Employees --> EditEmployee[Edit Employee]
    Employees --> DeleteEmployee[Delete Employee]
    Employees --> EmployeeCertificates[Employee Certificates]
    EmployeeCertificates --> ViewCertificate[View Certificate]
    
    %% Trainings management
    AdminDashboard --> Trainings[Trainings]
    Trainings --> EditTrainingInfo[Edit Training Info]
    Trainings --> EditTrainingPresentation[Edit Training Presentation]
    Trainings --> CreateTraining[Create Training]
    Trainings --> DeleteTraining[Delete Training]
    Trainings --> ViewPresentation1[View Presentation 1]
    Trainings --> ViewPresentation2[View Presentation 2]
    Trainings --> ViewPresentation3[View Presentation 3]
    CreateTraining --> AddPresentation[Add Presentation]
    
    %% Payments and Reports
    AdminDashboard --> PaymentsHistory[Payments History]
    AdminDashboard --> Reports[Reports]
    Reports --> DownloadPDF[Download PDF]
    
    %% Home navigation
    AdminDashboard --> HomePage[Home Page]
    
    %% Style definitions
    classDef userRole fill:#f9f,stroke:#333,stroke-width:2px;
    classDef dashboard fill:#bbf,stroke:#333,stroke-width:1px;
    classDef action fill:#dfd,stroke:#333,stroke-width:1px;
    
    %% Apply styles
    class Admin userRole;
    class AdminDashboard dashboard;
    class CreateCustomer,EditCustomer,DeleteCustomer,CreateVendor,EditVendor,DeleteVendor,CreateEmployee,EditEmployee,DeleteEmployee,EditTrainingInfo,EditTrainingPresentation,CreateTraining,DeleteTraining,AddPresentation,DownloadPDF action;
```

## 3. Customer User Journey

```mermaid
graph TD
    Customer([Customer]) --> CustomerDashboard[Dashboard]
    
    %% Profile
    CustomerDashboard --> CustomerProfile[My Profile]
    
    %% Vendors management
    CustomerDashboard --> CustomerVendors[Vendors]
    CustomerVendors --> CustomerCreateVendor[Create Vendor]
    CustomerVendors --> CustomerEditVendor[Edit Vendor]
    
    %% Employees management
    CustomerDashboard --> CustomerEmployees[Employees]
    CustomerEmployees --> CustomerCreateEmployee[Create Employee]
    CustomerEmployees --> CustomerEditEmployee[Edit Employee]
    CustomerEmployees --> CustomerEmployeeCertificates[Employee Certificates]
    CustomerEmployeeCertificates --> CustomerViewCertificate[View Certificate]
    CustomerViewCertificate --> ShareCertificate[Share Certificate with email]
    CustomerViewCertificate --> DownloadCertificate[Download Certificate]
    
    %% Training management
    CustomerDashboard --> CustomerTrainingList[Training List]
    CustomerTrainingList --> ViewTrainingInfo[View Training Info]
    CustomerTrainingList --> ViewPresentation1[View Presentation 1]
    CustomerTrainingList --> ViewPresentation2[View Presentation 2]
    CustomerTrainingList --> ViewPresentation3[View Presentation 3]
    CustomerTrainingList --> SendTrainingRequest[Send Training Request]
    
    %% Style definitions
    classDef userRole fill:#f9f,stroke:#333,stroke-width:2px;
    classDef dashboard fill:#bbf,stroke:#333,stroke-width:1px;
    classDef action fill:#dfd,stroke:#333,stroke-width:1px;
    
    %% Apply styles
    class Customer userRole;
    class CustomerDashboard dashboard;
    class CustomerCreateVendor,CustomerEditVendor,CustomerCreateEmployee,CustomerEditEmployee,ShareCertificate,DownloadCertificate,SendTrainingRequest action;
```

## 4. Vendor User Journey

```mermaid
graph TD
    Vendor([Vendor]) --> VendorDashboard[Dashboard]
    
    %% Profile
    VendorDashboard --> VendorProfile[My Profile]
    
    %% Employees management
    VendorDashboard --> VendorEmployees[Employees]
    VendorEmployees --> VendorCreateEmployee[Create Employee]
    VendorEmployees --> VendorEditEmployee[Edit Employee]
    VendorEmployees --> VendorEmployeeCertificates[Employee Certificates]
    VendorEmployeeCertificates --> VendorViewCertificate[View Certificate]
    VendorViewCertificate --> VendorShareCertificate[Share Certificate with email]
    VendorViewCertificate --> VendorDownloadCertificate[Download Certificate]
    
    %% Training management
    VendorDashboard --> VendorTrainingRequests[Training Requests]
    VendorTrainingRequests --> VendorTrainingInfo[Training Info]
    VendorTrainingRequests --> VendorSendTrainingRequest[Send Training Request]
    VendorTrainingInfo --> PayForTraining[Pay for Training]
    
    %% Certificates
    VendorDashboard --> VendorCertificates[Certificates]
    VendorCertificates --> VendorViewCertificateMain[View Certificate]
    VendorViewCertificateMain --> VendorShareCertificateMain[Share Certificate with email]
    VendorViewCertificateMain --> VendorDownloadCertificateMain[Download Certificate]
    
    %% Style definitions
    classDef userRole fill:#f9f,stroke:#333,stroke-width:2px;
    classDef dashboard fill:#bbf,stroke:#333,stroke-width:1px;
    classDef action fill:#dfd,stroke:#333,stroke-width:1px;
    
    %% Apply styles
    class Vendor userRole;
    class VendorDashboard dashboard;
    class VendorCreateEmployee,VendorEditEmployee,VendorShareCertificate,VendorDownloadCertificate,VendorSendTrainingRequest,PayForTraining,VendorShareCertificateMain,VendorDownloadCertificateMain action;
```

## 5. Employee User Journey

```mermaid
graph TD
    Employee([Employee]) --> EmployeeDashboard[Dashboard]
    
    %% Certificates
    EmployeeDashboard --> EmployeeCertificates[Certificates]
    EmployeeCertificates --> EmployeeViewCertificate[View Certificate]
    EmployeeViewCertificate --> EmployeeShareCertificate[Share Certificate with email]
    EmployeeViewCertificate --> EmployeeDownloadCertificate[Download Certificate]
    
    %% Training
    EmployeeDashboard --> EmployeeTrainingRequests[Training Requests]
    EmployeeTrainingRequests --> EmployeeTrainingInfo[Training Info]
    EmployeeTrainingInfo --> PassTraining1[Pass Training 1]
    PassTraining1 --> PassTraining2[Pass Training 2]
    PassTraining2 --> PassTraining3[Pass Training 3]
    PassTraining3 --> TrainingResults[Training Results]
    
    %% Style definitions
    classDef userRole fill:#f9f,stroke:#333,stroke-width:2px;
    classDef dashboard fill:#bbf,stroke:#333,stroke-width:1px;
    classDef action fill:#dfd,stroke:#333,stroke-width:1px;
    classDef training fill:#ffd,stroke:#333,stroke-width:1px;
    
    %% Apply styles
    class Employee userRole;
    class EmployeeDashboard dashboard;
    class EmployeeShareCertificate,EmployeeDownloadCertificate action;
    class PassTraining1,PassTraining2,PassTraining3,TrainingResults training;
```

## 6. Authentication Workflow

```mermaid
graph TD
    Start([Start]) --> Guest[Guest User]
    Guest --> Login{Login?}
    Login -->|Yes| Credentials[Enter Credentials]
    Login -->|No| Register[Register]
    
    Register --> SelectRole{Select Role}
    SelectRole -->|Employee| EmployeeRegistration[Employee Registration]
    SelectRole -->|Vendor| VendorRegistration[Vendor Registration]
    
    EmployeeRegistration --> SubmitEmployeeInfo[Submit Employee Information]
    VendorRegistration --> SubmitVendorInfo[Submit Vendor Information]
    
    SubmitEmployeeInfo --> AwaitApproval[Await Approval]
    SubmitVendorInfo --> AwaitApproval
    
    Credentials --> Authenticate{Authenticate}
    Authenticate -->|Success| DetermineRole{Determine Role}
    Authenticate -->|Failure| LoginError[Login Error]
    LoginError --> Login
    
    DetermineRole -->|Admin| AdminDashboard[Admin Dashboard]
    DetermineRole -->|Customer| CustomerDashboard[Customer Dashboard]
    DetermineRole -->|Vendor| VendorDashboard[Vendor Dashboard]
    DetermineRole -->|Employee| EmployeeDashboard[Employee Dashboard]
    
    %% Style definitions
    classDef start fill:#f96,stroke:#333,stroke-width:2px;
    classDef process fill:#dfd,stroke:#333,stroke-width:1px;
    classDef decision fill:#cff,stroke:#333,stroke-width:1px;
    classDef dashboard fill:#bbf,stroke:#333,stroke-width:1px;
    classDef error fill:#fcc,stroke:#333,stroke-width:1px;
    
    %% Apply styles
    class Start start;
    class Guest,Credentials,Register,EmployeeRegistration,VendorRegistration,SubmitEmployeeInfo,SubmitVendorInfo,AwaitApproval process;
    class Login,SelectRole,Authenticate,DetermineRole decision;
    class AdminDashboard,CustomerDashboard,VendorDashboard,EmployeeDashboard dashboard;
    class LoginError error;
```

## 7. Training Management Workflow

```mermaid
graph TD
    %% Admin Training Management
    Admin([Admin]) --> AdminTrainings[Trainings]
    AdminTrainings --> CreateTraining[Create Training]
    CreateTraining --> AddPresentation[Add Presentation]
    AdminTrainings --> EditTrainingInfo[Edit Training Info]
    AdminTrainings --> EditTrainingPresentation[Edit Training Presentation]
    AdminTrainings --> ViewTrainingPresentation[View Presentation]
    AdminTrainings --> DeleteTraining[Delete Training]
    
    %% Customer Training Flow
    Customer([Customer]) --> CustomerTrainingList[Training List]
    CustomerTrainingList --> ViewTrainingInfo[View Training Info]
    CustomerTrainingList --> ViewPresentation[View Presentation]
    CustomerTrainingList --> SendTrainingRequest[Send Training Request]
    
    %% Vendor Training Flow
    Vendor([Vendor]) --> VendorTrainingRequests[Training Requests]
    VendorTrainingRequests --> VendorTrainingInfo[Training Info]
    VendorTrainingInfo --> PayForTraining[Pay for Training]
    VendorTrainingRequests --> SendTrainingRequestToEmployee[Send Training Request]
    
    %% Employee Training Flow
    Employee([Employee]) --> EmployeeTrainingRequests[Training Requests]
    EmployeeTrainingRequests --> EmployeeTrainingInfo[Training Info]
    EmployeeTrainingInfo --> TakeTraining[Take Training]
    TakeTraining --> PassTraining1[Pass Training 1]
    PassTraining1 --> PassTraining2[Pass Training 2]
    PassTraining2 --> PassTraining3[Pass Training 3]
    PassTraining3 --> TrainingResults[Training Results]
    TrainingResults --> GenerateCertificate[Generate Certificate]
    
    %% Style definitions
    classDef userRole fill:#f9f,stroke:#333,stroke-width:2px;
    classDef training fill:#ffd,stroke:#333,stroke-width:1px;
    classDef action fill:#dfd,stroke:#333,stroke-width:1px;
    
    %% Apply styles
    class Admin,Customer,Vendor,Employee userRole;
    class AdminTrainings,CustomerTrainingList,VendorTrainingRequests,EmployeeTrainingRequests,EmployeeTrainingInfo,VendorTrainingInfo training;
    class CreateTraining,AddPresentation,EditTrainingInfo,EditTrainingPresentation,DeleteTraining,SendTrainingRequest,PayForTraining,SendTrainingRequestToEmployee,TakeTraining,PassTraining1,PassTraining2,PassTraining3,GenerateCertificate action;
```

## 8. Certificate Management Workflow

```mermaid
graph TD
    %% Certificate Generation
    TrainingCompletion[Training Completion] --> GenerateCertificate[Generate Certificate]
    GenerateCertificate --> StoreCertificate[Store Certificate]
    
    %% Certificate Access by Role
    StoreCertificate --> AccessByRole{Access By Role}
    
    %% Admin Certificate Access
    AccessByRole --> AdminAccess[Admin Access]
    AdminAccess --> AdminEmployees[Employees]
    AdminEmployees --> EmployeeCertificates[Employee Certificates]
    EmployeeCertificates --> ViewCertificate[View Certificate]
    
    %% Customer Certificate Access
    AccessByRole --> CustomerAccess[Customer Access]
    CustomerAccess --> CustomerEmployees[Employees]
    CustomerEmployees --> CustomerEmployeeCertificates[Employee Certificates]
    CustomerEmployeeCertificates --> CustomerViewCertificate[View Certificate]
    CustomerViewCertificate --> ShareCertificate[Share Certificate with email]
    CustomerViewCertificate --> DownloadCertificate[Download Certificate]
    
    %% Vendor Certificate Access
    AccessByRole --> VendorAccess[Vendor Access]
    VendorAccess --> VendorEmployees[Employees]
    VendorEmployees --> VendorEmployeeCertificates[Employee Certificates]
    VendorEmployeeCertificates --> VendorViewCertificate[View Certificate]
    VendorViewCertificate --> VendorShareCertificate[Share Certificate with email]
    VendorViewCertificate --> VendorDownloadCertificate[Download Certificate]
    
    VendorAccess --> VendorCertificates[Vendor Certificates]
    VendorCertificates --> VendorViewOwnCertificate[View Certificate]
    VendorViewOwnCertificate --> VendorShareOwnCertificate[Share Certificate with email]
    VendorViewOwnCertificate --> VendorDownloadOwnCertificate[Download Certificate]
    
    %% Employee Certificate Access
    AccessByRole --> EmployeeAccess[Employee Access]
    EmployeeAccess --> EmployeeCertificatesView[Certificates]
    EmployeeCertificatesView --> EmployeeViewCertificate[View Certificate]
    EmployeeViewCertificate --> EmployeeShareCertificate[Share Certificate with email]
    EmployeeViewCertificate --> EmployeeDownloadCertificate[Download Certificate]
    
    %% Style definitions
    classDef process fill:#dfd,stroke:#333,stroke-width:1px;
    classDef decision fill:#cff,stroke:#333,stroke-width:1px;
    classDef access fill:#bbf,stroke:#333,stroke-width:1px;
    classDef action fill:#ffd,stroke:#333,stroke-width:1px;
    
    %% Apply styles
    class TrainingCompletion,GenerateCertificate,StoreCertificate process;
    class AccessByRole decision;
    class AdminAccess,CustomerAccess,VendorAccess,EmployeeAccess access;
    class ShareCertificate,DownloadCertificate,VendorShareCertificate,VendorDownloadCertificate,VendorShareOwnCertificate,VendorDownloadOwnCertificate,EmployeeShareCertificate,EmployeeDownloadCertificate action;
```

## 9. Entity Relationship Diagram

```mermaid
erDiagram
    USER {
        id int PK
        email string
        password_digest string
        role string
        created_at datetime
        updated_at datetime
    }
    
    CUSTOMER {
        id int PK
        user_id int FK
        name string
        contact_info string
        created_at datetime
        updated_at datetime
    }
    
    VENDOR {
        id int PK
        user_id int FK
        customer_id int FK
        name string
        contact_info string
        created_at datetime
        updated_at datetime
    }
    
    EMPLOYEE {
        id int PK
        user_id int FK
        vendor_id int FK
        name string
        contact_info string
        created_at datetime
        updated_at datetime
    }
    
    TRAINING {
        id int PK
        title string
        description text
        created_by int FK
        created_at datetime
        updated_at datetime
    }
    
    PRESENTATION {
        id int PK
        training_id int FK
        title string
        content text
        sequence int
        created_at datetime
        updated_at datetime
    }
    
    TRAINING_REQUEST {
        id int PK
        training_id int FK
        vendor_id int FK
        employee_id int FK
        status string
        created_at datetime
        updated_at datetime
    }
    
    CERTIFICATE {
        id int PK
        employee_id int FK
        training_id int FK
        issue_date datetime
        expiry_date datetime
        created_at datetime
        updated_at datetime
    }
    
    PAYMENT {
        id int PK
        vendor_id int FK
        training_id int FK
        amount decimal
        status string
        payment_date datetime
        created_at datetime
        updated_at datetime
    }
    
    USER ||--o{ CUSTOMER : "has"
    USER ||--o{ VENDOR : "has"
    USER ||--o{ EMPLOYEE : "has"
    CUSTOMER ||--o{ VENDOR : "has"
    VENDOR ||--o{ EMPLOYEE : "has"
    USER ||--o{ TRAINING : "creates"
    TRAINING ||--o{ PRESENTATION : "has"
    VENDOR ||--o{ TRAINING_REQUEST : "makes"
    EMPLOYEE ||--o{ TRAINING_REQUEST : "receives"
    TRAINING ||--o{ TRAINING_REQUEST : "requested for"
    EMPLOYEE ||--o{ CERTIFICATE : "earns"
    TRAINING ||--o{ CERTIFICATE : "issues"
    VENDOR ||--o{ PAYMENT : "makes"
    TRAINING ||--o{ PAYMENT : "paid for"
```

## 10. Page Structure Diagram

```mermaid
graph TD
    %% Common Page Structure
    Page[Page] --> Header[Header]
    Page --> MainContent[Main Content]
    Page --> Footer[Footer]
    
    %% Header Components
    Header --> Logo[Logo]
    Header --> Navigation[Navigation Menu]
    Header --> UserInfo[User Info/Avatar]
    Header --> Notifications[Notifications]
    
    %% Main Content Components
    MainContent --> Sidebar[Sidebar]
    MainContent --> ContentArea[Content Area]
    
    %% Sidebar Components
    Sidebar --> UserRole[User Role]
    Sidebar --> MainNavigation[Main Navigation]
    Sidebar --> QuickLinks[Quick Links]
    
    %% Content Area Components
    ContentArea --> PageTitle[Page Title]
    ContentArea --> ActionButtons[Action Buttons]
    ContentArea --> DataTable[Data Table/List]
    ContentArea --> Forms[Forms]
    ContentArea --> DetailView[Detail View]
    ContentArea --> Pagination[Pagination]
    
    %% Footer Components
    Footer --> Copyright[Copyright]
    Footer --> SupportLinks[Support Links]
    Footer --> PrivacyLinks[Privacy Links]
    
    %% Style definitions
    classDef pageSection fill:#f9f,stroke:#333,stroke-width:2px;
    classDef component fill:#dfd,stroke:#333,stroke-width:1px;
    classDef subcomponent fill:#cff,stroke:#333,stroke-width:1px;
    
    %% Apply styles
    class Page,Header,MainContent,Footer pageSection;
    class Logo,Navigation,UserInfo,Notifications,Sidebar,ContentArea component;
    class UserRole,MainNavigation,QuickLinks,PageTitle,ActionButtons,DataTable,Forms,DetailView,Pagination,Copyright,SupportLinks,PrivacyLinks subcomponent;
```

## 11. Data Flow Diagram

```mermaid
flowchart TD
    %% External Entities
    Admin([Admin])
    Customer([Customer])
    Vendor([Vendor])
    Employee([Employee])
    
    %% Processes
    P1[Authentication Process]
    P2[User Management]
    P3[Training Management]
    P4[Certificate Management]
    P5[Payment Processing]
    P6[Reporting System]
    
    %% Data Stores
    DS1[(User Data)]
    DS2[(Training Data)]
    DS3[(Certificate Data)]
    DS4[(Payment Data)]
    
    %% Data Flows - Authentication
    Admin -->|Login Credentials| P1
    Customer -->|Login Credentials| P1
    Vendor -->|Login Credentials| P1
    Employee -->|Login Credentials| P1
    P1 -->|Verify| DS1
    P1 -->|Session Token| Admin
    P1 -->|Session Token| Customer
    P1 -->|Session Token| Vendor
    P1 -->|Session Token| Employee
    
    %% Data Flows - User Management
    Admin -->|Create/Edit/Delete Users| P2
    Customer -->|Create/Edit Vendors| P2
    Vendor -->|Create/Edit Employees| P2
    P2 -->|Store User Data| DS1
    P2 -->|User Data| Admin
    P2 -->|Vendor Data| Customer
    P2 -->|Employee Data| Vendor
    
    %% Data Flows - Training Management
    Admin -->|Create/Edit Trainings| P3
    Customer -->|Request Training| P3
    Vendor -->|Assign Training| P3
    Employee -->|Complete Training| P3
    P3 -->|Store Training Data| DS2
    P3 -->|Training Data| Admin
    P3 -->|Training Status| Customer
    P3 -->|Training Assignments| Vendor
    P3 -->|Training Content| Employee
    
    %% Data Flows - Certificate Management
    P3 -->|Training Completion| P4
    P4 -->|Generate Certificate| DS3
    P4 -->|Certificate Data| Admin
    P4 -->|Employee Certificates| Customer
    P4 -->|Employee Certificates| Vendor
    P4 -->|Personal Certificate| Employee
    
    %% Data Flows - Payment Processing
    Vendor -->|Make Payment| P5
    P5 -->|Store Payment Data| DS4
    P5 -->|Payment Confirmation| Vendor
    P5 -->|Payment Records| Admin
    
    %% Data Flows - Reporting
    DS1 -->|User Statistics| P6
    DS2 -->|Training Statistics| P6
    DS3 -->|Certificate Statistics| P6
    DS4 -->|Payment Statistics| P6
    P6 -->|Reports| Admin
    P6 -->|Limited Reports| Customer
    
    %% Style definitions
    classDef entity fill:#f9f,stroke:#333,stroke-width:2px;
    classDef process fill:#bbf,stroke:#333,stroke-width:1px;
    classDef datastore fill:#dfd,stroke:#333,stroke-width:1px;
    
    %% Apply styles
    class Admin,Customer,Vendor,Employee entity;
    class P1,P2,P3,P4,P5,P6 process;
    class DS1,DS2,DS3,DS4 datastore;
