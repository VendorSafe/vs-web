# Integration Plan Checklist

## 1. Database Schema Updates ⏳ In Progress

### New Tables/Fields Required
- [x] Add progress fields to training_memberships
  - Added completion tracking
  - Added sequential progression support
  - Added team-based access control
- [x] Add state to training_programs
  - Added workflow states (draft, published, archived)
  - Added state transition guards
- [x] Add question type to training_questions
  - Added support for different question formats
- [x] Add content fields to training_contents
  - Added type-specific content storage
  - Added completion criteria
  - Added dependencies tracking
- [x] Configure activities table for tracking
  - Using jsonb for parameters
  - Added team-based ownership
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

## 2. Model Enhancements ✅ Mostly Complete

### TrainingProgram Model
- [x] Add validations for new fields
- [x] Add completion deadline calculations
- [x] Add methods for progress tracking
- [x] Add certificate generation
- [x] Replace custom invitations with Bullet Train system
- [x] Implement workflow state management:
  - [x] States: draft, published, archived
  - [x] Events: publish, unpublish, archive, restore
  - [x] State-specific validations and behaviors
  - [x] Role-based guards for state transitions

### TrainingContent Model
- [x] Add content type specific validations
- [x] Add time tracking methods
- [x] Add progress calculation
- [x] Add media handling
- [x] Implement sequential content progression:
  - [x] Content must be completed in order
  - [x] Support for different content types:
    - [x] Slide carousels with navigation
    - [x] Video content with completion tracking
    - [x] Text/article content with scroll tracking
    - [x] Interactive quizzes
    - [x] Audio content with playback tracking
- [x] Add position/ordering field for content sequence
- [x] Add dependencies between content items
- [x] Add completion criteria for each content type
- [x] Add activity tracking

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

## 4. Authentication & Authorization ✅ Complete

### Authentication Flow (Using Bullet Train)
- [x] Leveraging Bullet Train's authentication system:
  - [x] Devise-based user authentication
  - [x] Team-based multitenancy
  - [x] Built-in invitation system
- [ ] Integration with NextJS:
  - [ ] Token-based API authentication
  - [ ] Session management
  - [ ] Real-time updates
- [x] Team invitation workflow:
  - [x] Team admins invite new members
  - [x] Automatic role assignment on acceptance
  - [x] Training role management through team UI
- [ ] Optional SSO integration (Future Phase):
  - [ ] Support for OAuth providers
  - [ ] Enterprise SSO options
  - [ ] Role mapping for SSO users

### Authorization (Using Bullet Train Roles)
- [x] Implemented role system with custom roles:
  - [x] employee: Team member taking training
  - [x] vendor: Team manager with training access
  - [x] customer: Creates and manages training programs
- [x] Role-based workflow restrictions:
  - [x] Draft programs only visible to authors/admins
  - [x] Publishing requires appropriate role
  - [x] Archiving requires admin role
- [x] Content access restrictions:
  - [x] Sequential content progression
  - [x] Prerequisite validation
  - [x] Progress-based unlocking
- [x] Certificate management:
  - [x] Role-based certificate generation
  - [x] Validity period enforcement
  - [x] Verification system access control

Note: Role system has been updated to align with business requirements:
- Replaced training_viewer/participant/author/admin with employee/vendor/customer
- Added team-based access control
- Integrated with activity tracking

## 5. Design System Integration ⏳ In Progress

### Color System ✅ Defined
- [x] Primary Colors:
  - [x] Primary: #eab308 (yellow-500)
  - [x] Primary Dark: #ca8a04 (yellow-600)
  - [x] Secondary: #1e293b (slate-800)
- [ ] Gradient Patterns (Pending Implementation):
  - [ ] Hero gradient: radial-gradient(circle, #2A3B4C 0%, #162434 100%)
  - [ ] Section gradients with yellow/slate overlays
  - [ ] Interactive hover states using primary colors

### Typography ⏳ In Progress
- [x] Fonts Selected:
  - [x] Headers: 'Fraunces', serif
  - [x] Body: 'DM Sans', sans-serif
- [ ] Text Styles (Pending Implementation):
  - [ ] Headings with tight tracking
  - [ ] Subtitle class with relaxed leading
  - [ ] Responsive font sizing

### Component Styles 🔄 To Be Started
- [ ] Navigation:
  - [ ] Scrolled state with background blur
  - [ ] Hover effects using primary colors
  - [ ] Mobile-responsive menu
- [ ] Buttons:
  - [ ] Primary: Yellow with dark text
  - [ ] Secondary: Slate with light text
  - [ ] Hover states with color transitions
- [ ] Cards:
  - [ ] Gradient backgrounds
  - [ ] Shadow effects
  - [ ] Hover transitions

### Animation System 🔄 To Be Started
- [ ] Transitions:
  - [ ] fade-in: Opacity and Y-axis transform
  - [ ] slide-in: X-axis transform with fade
  - [ ] Progress bars with linear transitions
- [ ] Gradients:
  - [ ] Pulse animation for hero section
  - [ ] Floating effect for background elements
  - [ ] Smooth scroll behavior

### Layout Patterns 🔄 To Be Started
- [ ] Container:
  - [ ] Centered with 2rem padding
  - [ ] Responsive breakpoints
- [ ] Hero Sections:
  - [ ] Full-width gradients
  - [ ] Slide-based content
  - [ ] Progress indicators
- [ ] Section Layouts:
  - [ ] Stats layout with centered headings
  - [ ] Features layout with grid system
  - [ ] Split layout for content/media

Note: Design system implementation will follow Bullet Train's theming approach:
- Using Tailwind CSS for utility classes
- Extending Bullet Train's light theme
- Implementing custom components through view components

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

### Phase 1: Foundation & Design System (Weeks 1-2)
- Database migrations
- Basic model implementations
- Initial NextJS setup
- Design system implementation:
  - Color system and gradients
  - Typography setup
  - Base component styles
  - Animation system
  - Layout patterns

### Phase 2: Core Features & UI (Weeks 3-4)
- API development
- Design-driven component development:
  - Navigation with transitions
  - Hero sections with animations
  - Content cards with gradients
  - Form elements with custom styling
- Authentication integration

### Phase 3: Enhanced Features & Visual Polish (Weeks 5-6)
- Advanced content handling with custom styling
- Certificate system with branded design
- Progress tracking with animated indicators
- Interactive elements and transitions
- Responsive design implementation

### Phase 4: Testing & Optimization (Weeks 7-8)
- UI/UX refinement and consistency
- Performance optimization:
  - Animation performance
  - Gradient rendering
  - Asset optimization
- Cross-browser testing
- Documentation
- Deployment preparation

## Notes

### Design Considerations
- Maintain consistent brand identity
- Ensure accessibility with color contrast
- Optimize animations for performance
- Support dark/light mode themes
- Follow responsive design principles
- Implement progressive enhancement

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