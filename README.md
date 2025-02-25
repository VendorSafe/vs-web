# VendorSafe Web Application

VendorSafe is a comprehensive training and compliance management platform built on Ruby on Rails with Bullet Train and Vue.js.

## Features

- Role-based access control (Customer, Vendor, Employee)
- Interactive training program viewer
- Certificate generation and management
- Progress tracking and analytics
- Team-based organization structure

## Getting Started

### Prerequisites

- Ruby 3.2+
- Node.js 18+
- PostgreSQL 14+
- Redis

### Installation

1. Clone the repository:
```bash
git clone git@github.com:your-org/vendorsafe.git
cd vendorsafe
```

2. Install dependencies:
```bash
bundle install
yarn install
```

3. Setup database:
```bash
bin/rails db:create db:migrate
```

4. Start the development server:
```bash
bin/dev
```

## Demo Environment

We provide a complete demo environment to explore all features across different user roles.

### Setting Up Demo

1. Run the demo setup script:
```bash
bin/setup-demo
```

2. Start the server:
```bash
bin/dev
```

3. Access the application at http://localhost:3000

### Demo Accounts

- Customer: `demo.customer@vendorsafe.app` / `customer123`
- Vendor: `demo.vendor@vendorsafe.app` / `vendor123`
- Employee: `demo.employee@vendorsafe.app` / `employee123`

### Demo Workflows

See [DEMO_WORKFLOW.md](docs/DEMO_WORKFLOW.md) for detailed workflows for each user role, including:
- Customer: Managing vendors and training programs
- Vendor: Managing employees and tracking compliance
- Employee: Completing training and accessing certificates

## Documentation

- [Integration Plan](docs/INTEGRATION-PLAN.md)
- [Milestones](docs/MILESTONES.md)
- [Implementation Status](docs/IMPLEMENTATION-STATUS.md)
- [Directory Structure](docs/DIRECTORY_STRUCTURE.md)
- [Roles](docs/ROLES.md)

## Development

### Key Components

- **Training Program Viewer**: Vue.js-based interactive viewer with video player and quiz system
- **Certificate Generator**: PDF generation with custom templates and QR verification
- **Progress Tracking**: Real-time progress tracking with analytics
- **Role Management**: Comprehensive role-based access control

### Running Tests

```bash
bin/rails test                 # Run unit tests
bin/rails test:system         # Run system tests
```

### Code Style

```bash
bin/rubocop                   # Ruby style checker
yarn lint                     # JavaScript style checker
```

## Production Deployment

1. Configure environment variables:
```bash
cp config/application.yml.example config/application.yml
# Edit application.yml with your production values
```

2. Precompile assets:
```bash
bin/rails assets:precompile
```

3. Run migrations:
```bash
bin/rails db:migrate
```

## Contributing

1. Fork the repository
2. Create your feature branch: `git checkout -b feature/my-feature`
3. Commit your changes: `git commit -am 'Add new feature'`
4. Push to the branch: `git push origin feature/my-feature`
5. Create a Pull Request

## License

This project is licensed under the MIT License - see the [MIT-LICENSE](MIT-LICENSE) file for details.