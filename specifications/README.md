# UI Specifications Documentation

## Overview
This document catalogs the UI mockups for the training management system, organized by user role and functionality.

## Admin Interface (a-*)

### User Management
- **Customer Management** (`a-create-customer.png`, `a-edit-customer.png`)
  - Create/edit customer profiles
  - Manage multiple addresses (up to 100)
  - Required fields: Name, Email, Phone, Company Name

- **Employee Management** (`a-create-employee.png`, `a-edit-employee.png`)
  - Create/edit employee profiles
  - Link employees to vendors
  - Collect SSN (last 4 digits) and birthday

- **Vendor Management** (`a-create-vendor.png`, `a-edit-vendor.png`)
  - Create/edit vendor profiles
  - Multiple address support (up to 5)
  - Auto-suggestion for email/name fields

### Training Management
- **Presentation Editor** (`a-add-presentation.png`, `a-edit-training-presentation.png`)
  - Add text, images, video, audio
  - Set slide time limits
  - Question management with multiple answers
  - Slide navigation and ordering

- **Training Configuration** (`a-create-training.png`, `a-edit-training-info.png`)
  - Set passing percentage
  - Configure pricing
  - Manage training content

### Reporting & Certificates
- **Certificate Management** (`a-certificates.png`, `a-view-certificate.png`)
  - Generate certificates
  - Download/share options
  - Certificate template customization

- **Payment History** (`a-payments-history.png`)
  - Transaction records
  - Sort by date (newest first)
  - Payment amount tracking

## Customer Interface (c-*)

### Employee Management
- **Employee Operations** (`c-create-employee.png`, `c-edit-employee.png`)
  - Basic employee information
  - Certificate viewing
  - Training assignment

### Training Management
- **Training Interface** (`c-view-presentation-1-.png`, `c-view-presentation-2-.png`)
  - View training content
  - Progress tracking
  - Certificate access

## Employee Interface (e-*)

### Training Experience
- **Certificate Management** (`e-certificates.png`)
  - View earned certificates
  - Download options
  - Training history

- **Training Interface** (`pass-training-1-.png`, `pass-training-2-.png`, `pass-training-3-.png`)
  - Interactive training content
  - Progress tracking
  - Quiz/assessment interface

## Vendor Interface (v-*)

### Employee Management
- **Employee Dashboard** (`v-employees.png`, `v-create-employee.png`)
  - Employee listing
  - Certificate tracking
  - Training assignment

### Training Management
- **Training Requests** (`v-training-requests.png`)
  - View pending requests
  - Track completion status
  - Manage certifications

## Shared Components

### Navigation
- Consistent header with logo and main navigation
- Role-specific menu items
- Search functionality in listings

### Lists and Tables
- Pagination (5 items per page)
- Sortable columns
- Action buttons (View, Download, Delete)

### Forms
- Required field indicators (*)
- Validation feedback
- Cancel/Save actions
- Address management

## Notes
- All interfaces include responsive design considerations
- Consistent styling across all views
- Role-based access control implemented throughout
- Yellow sticky notes indicate special functionality or requirements 