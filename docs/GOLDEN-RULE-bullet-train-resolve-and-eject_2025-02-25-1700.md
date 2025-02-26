# Golden Rule: Bullet Train Resolve and Copy Process

**Date**: February 25, 2025  
**Time**: 5:01 PM PST  
**Category**: Development Guidelines

## Rule

When encountering missing Bullet Train files (e.g., views, partials, controllers), use the `bin/resolve` command to locate the file in the Bullet Train gems, then manually copy it to your local project maintaining the same directory structure if modifications are needed.

## Example

```bash
# When encountering a missing file error like:
# File not found: app/views/account/shared/box.html.erb

# Step 1: Use resolve to find the file in Bullet Train gems
bin/resolve app/views/account/shared/box

# Step 2: Note the absolute path and package name
# e.g., vendor/bundle/ruby/3.3.0/gems/bullet_train-themes-light-1.12.0/app/views/themes/light/_box.html.erb

# Step 3: Copy the file to your project maintaining the directory structure
cp vendor/bundle/ruby/3.3.0/gems/bullet_train-themes-light-1.12.0/app/views/themes/light/_box.html.erb app/views/themes/light/_box.html.erb
```

## Why It's Good

- Ensures proper handling of Bullet Train's modular architecture
- Maintains consistency with Bullet Train's conventions
- Prevents duplicate implementations
- Makes customizations traceable and maintainable

## Why It's Bad When Violated

- May create inconsistencies with Bullet Train's core functionality
- Could lead to duplicate implementations
- Makes upgrades more difficult
- May break expected behavior patterns

## Best Practices

1. Always use `bin/resolve` first to locate missing files
2. Only copy files when local modifications are necessary
3. Document copied files and reasons for customization
4. Keep track of copied files for future upgrades
5. Maintain the same directory structure as in the gem
6. Create any necessary parent directories before copying

## Common Issues

- File might exist in multiple Bullet Train gems
- Copied files may need updates during Bullet Train upgrades
- Dependencies between files may require copying multiple files
- Some files may require additional setup after copying
- Directory structure must match exactly for proper resolution

## Real World Example

During the implementation of the VendorSafe training platform (February 25, 2025), we encountered this exact scenario:

1. Missing box.html.erb partial

   - First discovered when trying to render location views
   - Used `bin/resolve` to locate the file in bullet_train-themes-light
   - Copied for custom styling requirements

2. Resolution process:

   ```bash
   bin/resolve app/views/account/shared/box
   # Found in: bullet_train-themes-light-1.12.0

   # Create directory if it doesn't exist
   mkdir -p app/views/themes/light/

   # Copy the file
   cp vendor/bundle/ruby/3.3.0/gems/bullet_train-themes-light-1.12.0/app/views/themes/light/_box.html.erb app/views/themes/light/_box.html.erb
   # Successfully copied to local project
   ```

This experience directly informed and validated this rule's creation.

## Implementation Notes

- Always check the resolved path carefully as it may contain version numbers
- Some files may need to be copied to a slightly different location in your project
- After copying, you may need to restart your Rails server
- Keep a log of copied files to track during upgrades
- Consider creating a script to automate the copy process for multiple files
