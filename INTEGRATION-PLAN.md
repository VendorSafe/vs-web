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
  - `content_type` (enum: text, video, audio, quiz, slides)
  - `time_limit` (integer, nullable) - Minutes allowed for this content
  - `media_url` (string, nullable) - For video/audio content
  - `is_required` (boolean) - Whether content must be completed
  - `position` (integer) - Order in training program sequence
  - `content_data` (jsonb) - Stores content based on type:
    - Slides: array of slide objects with text/images
    - Quiz: questions and answers
    - Text: formatted content and metadata
  - `completion_criteria` (jsonb) - Type-specific completion rules:
    - Video/Audio: percentage watched
    - Slides: all slides viewed
    - Quiz: passing score
    - Text: scroll percentage/time spent
  - `dependencies` (array) - IDs of content items that must be completed first
  - `version` (integer) - For tracking content updates
  - `last_updated_by` (foreign key to users) - Content editor tracking

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

## 2. Model Enhancements ([Bullet Train Model Architecture](./bullet-train-docs.md#model-architecture))

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
- Implement sequential content progression:
  - Content must be completed in order
  - Support for different content types:
    - Slide carousels with navigation
    - Video content with completion tracking
    - Text/article content with scroll tracking
    - Interactive quizzes
    - Audio content with playback tracking
- Add position/ordering field for content sequence
- Add dependencies between content items
- Add completion criteria for each content type

### Content Creation GUI
- Develop admin interface for content creation:
  - Drag-and-drop content ordering
  - Rich text editor for text content
  - Slide builder with image upload
  - Video/audio upload and embedding
  - Quiz builder with different question types
  - Preview mode for content review
  - Bulk content import/export
  - Content templates and reusable components
  - Version control for content updates

### User Model
- Add training program associations
- Add certificate associations
- Add progress tracking methods
- Add invitation handling

## 3. NextJS Integration (See [Bullet Train Frontend Docs](./bullet-train-docs.md#nextjs-integration))

### Setup
- Create new NextJS application in `/client`
- Configure proxy for API requests
- Set up authentication integration
- Configure shared types between Rails/NextJS

### Core Features
- Training dashboard
- Content viewer components:
  - Sequential content navigation system
  - Type-specific content renderers
  - Progress and completion tracking
  - Learning tools integration
- Content management system:
  - Content creation interface
  - Content organization tools
  - Version control system
- Progress tracking and analytics
- Certificate generation and management
- Invitation and access management

## 4. Authentication & Authorization (See [Bullet Train Auth Docs](./bullet-train-docs.md#authentication))

### Authentication Flow (Using Bullet Train)
- Leveraging Bullet Train's authentication system:
  - Devise-based user authentication
  - Team-based multitenancy
  - Built-in invitation system
- Integration with NextJS:
  - Token-based API authentication
  - Session management
  - Real-time updates
- Team invitation workflow:
  - Team admins invite new members
  - Automatic role assignment on acceptance
  - Training role management through team UI
- Optional SSO integration:
  - Support for OAuth providers
  - Enterprise SSO options
  - Role mapping for SSO users

### Authorization (Using Bullet Train Roles)
- Leveraging Bullet Train's built-in role system with custom training roles:
  - training_viewer: Read-only access to published content
  - training_participant: Can participate in programs and earn certificates
  - training_author: Can create/edit programs and manage content
  - training_admin: Full control of training system
- Role-based workflow restrictions:
  - Draft programs only visible to authors/admins
  - Publishing requires author/admin role
  - Archiving requires admin role
- Content access restrictions:
  - Sequential content progression
  - Prerequisite validation
  - Progress-based unlocking
- Certificate management:
  - Role-based certificate generation
  - Validity period enforcement
  - Verification system access control

## 5. Design System Integration

### Color System
- Primary Colors:
  - Primary: #eab308 (yellow-500)
  - Primary Dark: #ca8a04 (yellow-600)
  - Secondary: #1e293b (slate-800)
- Gradient Patterns:
  - Hero gradient: radial-gradient(circle, #2A3B4C 0%, #162434 100%)
  - Section gradients with yellow/slate overlays
  - Interactive hover states using primary colors

### Typography
- Fonts:
  - Headers: 'Fraunces', serif
  - Body: 'DM Sans', sans-serif
- Text Styles:
  - Headings with tight tracking
  - Subtitle class with relaxed leading
  - Responsive font sizing

### Component Styles
- Navigation:
  - Scrolled state with background blur
  - Hover effects using primary colors
  - Mobile-responsive menu
- Buttons:
  - Primary: Yellow with dark text
  - Secondary: Slate with light text
  - Hover states with color transitions
- Cards:
  - Gradient backgrounds
  - Shadow effects
  - Hover transitions

### Animation System
- Transitions:
  - fade-in: Opacity and Y-axis transform
  - slide-in: X-axis transform with fade
  - Progress bars with linear transitions
- Gradients:
  - Pulse animation for hero section
  - Floating effect for background elements
  - Smooth scroll behavior

### Layout Patterns
- Container:
  - Centered with 2rem padding
  - Responsive breakpoints
- Hero Sections:
  - Full-width gradients
  - Slide-based content
  - Progress indicators
- Section Layouts:
  - Stats layout with centered headings
  - Features layout with grid system
  - Split layout for content/media

## 6. Frontend Components

### Dashboard
- Training program list
- Progress tracking
- Certificate showcase
- Upcoming deadlines

### Content Viewer
- Sequential content navigation system:
  - Next/Previous content controls
  - Content type-specific viewers:
    - Slide carousel with navigation controls
    - Video player with progress tracking
    - Audio player with timestamps
    - Text viewer with scroll tracking
    - Interactive quiz interface with instant feedback
  - Progress indicators:
    - Overall training program progress
    - Current content item progress
    - Required vs optional content indicators
  - Time tracking features:
    - Content-specific time limits
    - Auto-save progress
    - Resume from last position
  - Learning aids:
    - Notes and annotations
    - Bookmarking capability
    - Content search (if allowed)
  - Technical features:
    - Offline content caching
    - Mobile-responsive design
    - Accessibility compliance

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