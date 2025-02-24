# Integration Plan: NextJS Training Program into Bullet Train Rails

## 1. Database Schema Updates

### New Tables/Fields Required
- Add to `training_programs`:
  - `completion_deadline` (datetime, nullable) - Absolute deadline
  - `completion_timeframe` (integer, nullable) - Days allowed from invitation
  - `passing_percentage` (integer) - Required score to pass
  - `time_limit` (integer, nullable) - Minutes allowed for completion
  - `is_published` (boolean) - Training visibility status

- Add to `training_contents`:
  - `content_type` (enum: text, video, audio, quiz)
  - `time_limit` (integer, nullable) - Minutes allowed for this content
  - `media_url` (string, nullable) - For video/audio content
  - `is_required` (boolean) - Whether content must be completed

- New table `training_invitations`:
  - `id` (primary key)
  - `training_program_id` (foreign key)
  - `invitee_id` (foreign key to users)
  - `inviter_id` (foreign key to users)
  - `status` (enum: pending, accepted, completed, expired)
  - `expires_at` (datetime)
  - `completed_at` (datetime, nullable)
  - `created_at`, `updated_at` timestamps

- New table `training_progress`:
  - `id` (primary key)
  - `user_id` (foreign key)
  - `training_program_id` (foreign key)
  - `training_content_id` (foreign key)
  - `status` (enum: not_started, in_progress, completed)
  - `score` (integer, nullable)
  - `time_spent` (integer) - Minutes spent
  - `last_accessed_at` (datetime)
  - `created_at`, `updated_at` timestamps

- New table `training_certificates`:
  - `id` (primary key)
  - `user_id` (foreign key)
  - `training_program_id` (foreign key)
  - `issued_at` (datetime)
  - `certificate_number` (string)
  - `score` (integer)
  - `created_at`, `updated_at` timestamps

## 2. Model Enhancements

### TrainingProgram Model
- Add validations for new fields
- Add completion deadline calculations
- Add methods for progress tracking
- Add certificate generation
- Add invitation management
- Implement workflow state management:
  - States: draft, published, archived
  - Events: publish, unpublish, archive, restore
  - State-specific validations and behaviors

### TrainingContent Model
- Add content type specific validations
- Add time tracking methods
- Add progress calculation
- Add media handling

### User Model
- Add training program associations
- Add certificate associations
- Add progress tracking methods
- Add invitation handling

## 3. NextJS Integration

### Setup
- Create new NextJS application in `/client`
- Configure proxy for API requests
- Set up authentication integration
- Configure shared types between Rails/NextJS

### Core Features
- Training dashboard
- Content viewer components
- Progress tracking
- Certificate generation
- Invitation management

## 4. Authentication & Authorization

### Authentication Flow
- Integrate Devise token auth with NextJS
- Handle SSO if required
- Manage session persistence
- Handle invitation-based access

### Authorization
- Role-based access control
- Content access restrictions
- Progress-based restrictions
- Certificate access control

## 5. Frontend Components

### Dashboard
- Training program list
- Progress tracking
- Certificate showcase
- Upcoming deadlines

### Content Viewer
- Multi-media content support
- Progress indicators
- Time tracking
- Quiz interface

### Certificate Management
- Certificate template
- Download options
- Sharing interface
- Verification system

## 6. API Development

### New Endpoints Required
- Training program management
- Content delivery
- Progress tracking
- Certificate generation
- Invitation management

### API Features
- Pagination
- Caching
- Rate limiting
- Error handling

## 7. Testing & Deployment

### Testing
- Model tests
- Controller tests
- API integration tests
- Frontend component tests
- End-to-end tests

### Deployment
- Configure build process
- Set up CI/CD pipeline
- Configure monitoring
- Set up error tracking

## Timeline & Milestones

### Phase 1: Foundation (Weeks 1-2)
- Database migrations
- Basic model implementations
- Initial NextJS setup

### Phase 2: Core Features (Weeks 3-4)
- API development
- Basic frontend components
- Authentication integration

### Phase 3: Enhanced Features (Weeks 5-6)
- Advanced content handling
- Certificate system
- Progress tracking

### Phase 4: Polish & Testing (Weeks 7-8)
- UI/UX refinement
- Testing
- Documentation
- Deployment preparation

## Notes

### Security Considerations
- Ensure proper authentication
- Implement rate limiting
- Secure file uploads
- Protect user data

### Performance Considerations
- Implement caching
- Optimize media delivery
- Use background jobs
- Monitor database performance

### Maintenance Considerations
- Document API endpoints
- Set up monitoring
- Plan backup strategy
- Configure error tracking