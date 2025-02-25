# VendorSafe CEMS Training Platform

A comprehensive Continuous Emissions Monitoring System (CEMS) training and certification platform built on Ruby on Rails with Bullet Train and Vue.js.

## Features

- Role-based access for Plant Managers, CEMS Supervisors, and Technicians
- Interactive CEMS training modules and certification tracking
- EPA compliance management and reporting
- Part 40 CFR 75 certification management
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

The platform includes a comprehensive demo environment that simulates interactions between power plants and CEMS service providers.

### Setting Up Demo Environments

Create one or more demo environments with the setup script:

```bash
# Create a single demo environment
bin/setup-demo

# Create multiple demo environments
bin/setup-demo 3  # Creates 3 separate environments
```

Each environment includes:
- A power generation company
- A CEMS service provider
- Pre-configured training programs
- Demo accounts for all roles

### Demo Workflows

See [DEMO_WORKFLOW.md](docs/DEMO_WORKFLOW.md) for detailed workflows including:
- Plant Manager: Managing CEMS compliance and vendor certifications
- CEMS Supervisor: Managing technician training and certifications
- CEMS Technician: Completing required training and maintaining qualifications

## Documentation

- [Integration Plan](docs/INTEGRATION-PLAN.md)
- [Milestones](docs/MILESTONES.md)
- [Implementation Status](docs/IMPLEMENTATION-STATUS.md)
- [Directory Structure](docs/DIRECTORY_STRUCTURE.md)
- [Roles](docs/ROLES.md)

## Development

### Key Components

- **CEMS Training Module**: Vue.js-based interactive training system
- **Certification Manager**: EPA-compliant certificate generation with verification
- **Progress Tracking**: Real-time certification progress monitoring
- **Compliance Reports**: Automated compliance reporting and alerts

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