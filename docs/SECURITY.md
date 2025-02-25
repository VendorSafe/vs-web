# Security Policy

This document outlines the security policy for the VendorSafe training platform.

Last updated: February 24, 2025

## Reporting a Vulnerability

Please report security issues to Andrew Culver privately [via DM on Twitter](https://twitter.com/andrewculver) or via DM after joining [the Bullet Train Discord server](https://discord.gg/bullettrain). (Please double check the profile you're messaging is marked as the "Server Owner".) 

If you don't have a reply within two business days, please contact [Adam Pallozzi](https://twitter.com/adampallozzi) and [Gabriel Zayas](https://twitter.com/gazayas) via DM on Twitter only. 

We do not currently have a bounty program.

## Security Practices

### Authentication

The VendorSafe platform uses Bullet Train's authentication system, which is built on Devise. Key security features include:

1. **Multi-factor Authentication**
   - Two-factor authentication support
   - TOTP (Time-based One-Time Password) implementation
   - QR code generation for authenticator apps

2. **Password Security**
   - Secure password hashing with bcrypt
   - Password complexity requirements
   - Password expiration policies
   - Breached password detection

3. **Session Management**
   - Secure session handling
   - Session timeout controls
   - Device tracking and management
   - Suspicious login detection

### Authorization

The platform implements a robust authorization system using CanCanCan:

1. **Role-Based Access Control**
   - Granular permission definitions
   - Role inheritance
   - Team-scoped permissions
   - Resource-level access control

2. **API Security**
   - OAuth 2.0 implementation with Doorkeeper
   - Token-based authentication
   - Scoped API access
   - Rate limiting

### Data Protection

The platform implements several measures to protect sensitive data:

1. **Encryption**
   - Database-level encryption for sensitive fields
   - TLS for all connections
   - Encrypted file storage
   - Secure key management

2. **Data Isolation**
   - Multi-tenant data isolation
   - Team-scoped queries
   - Proper database indexing
   - Query authorization

### Audit and Compliance

The platform includes comprehensive audit capabilities:

1. **Activity Tracking**
   - User action logging
   - Authentication event recording
   - Permission change tracking
   - Resource access logging

2. **Compliance Support**
   - Data export capabilities
   - Retention policy enforcement
   - Privacy policy implementation
   - GDPR compliance features

## Security Best Practices

When developing for the VendorSafe platform, follow these security best practices:

1. **Code Security**
   - Follow OWASP secure coding guidelines
   - Use parameterized queries to prevent SQL injection
   - Implement proper input validation
   - Sanitize all user inputs

2. **Authentication & Authorization**
   - Always use the built-in authentication system
   - Never bypass authorization checks
   - Test permission boundaries thoroughly
   - Use the principle of least privilege

3. **Data Handling**
   - Minimize sensitive data collection
   - Use encrypted attributes for sensitive information
   - Implement proper data retention policies
   - Follow data minimization principles

4. **API Security**
   - Validate all API inputs
   - Implement proper rate limiting
   - Use appropriate authentication for each endpoint
   - Follow REST best practices

## Security Updates

The VendorSafe platform follows Bullet Train's security update process:

1. **Dependency Management**
   - Regular dependency updates
   - Security vulnerability scanning
   - Automated update testing
   - Critical update notifications

2. **Patch Management**
   - Rapid response to security vulnerabilities
   - Coordinated disclosure process
   - Hotfix deployment procedures
   - Version tracking and notification

3. **Security Testing**
   - Regular penetration testing
   - Automated security scanning
   - Vulnerability assessment
   - Code review for security issues
