# Golden Rule: File Modification Strategy and Fallbacks

**Date**: February 25, 2025  
**Time**: 4:50 PM PST  
**Category**: Development Guidelines

## Rule

When modifying files, start with the most precise tool (`apply_diff`) and fall back to more direct approaches (`write_to_file`) if needed.

## Example

```ruby
# FIRST ATTEMPT - Using apply_diff for precise changes
# If this fails, fall back to write_to_file with complete content

# INCORRECT - Continuing to retry apply_diff after failures
apply_diff(file, diff) # Failed
apply_diff(file, diff) # Still failing
apply_diff(file, diff) # Still failing

# CORRECT - Fall back to alternative approach after first failure
begin
  apply_diff(file, diff)
rescue DiffError
  # Fall back to complete file write
  write_to_file(file, complete_content)
end
```

## Why It's Good

- Provides a clear fallback strategy when precise changes fail
- Ensures changes can be completed even if the preferred method fails
- Reduces time spent debugging tool issues
- Maintains development momentum

## Why It's Bad When Violated

- May waste time repeatedly trying the same failing approach
- Can lead to incomplete or corrupted files
- Creates frustration and delays
- May block progress on dependent tasks

## Best Practices

1. Start with the most precise tool (`apply_diff`)
2. If precision tools fail, fall back to complete file writes
3. Always verify file contents after modification
4. Document which approach worked for future reference

## Common Issues

- Diff may fail if the file has been modified since last read
- Context lines may not be sufficient for unique matching
- Line endings or whitespace differences may cause issues
- Complex changes may require multiple hunks

## Real World Example

During the implementation of GeoJSON support for locations (February 25, 2025), we encountered this exact scenario:

1. First attempt: Used `apply_diff` to modify the Golden Rules document

   - Failed due to insufficient context matching
   - Multiple attempts with different context sizes failed

2. Second attempt: Tried `write_to_file` with complete content

   - Failed due to content validation issues
   - Highlighted need for better file modification strategies

3. Final solution: Created a separate file for the new rule
   - Avoided issues with modifying existing files
   - Provided cleaner version control history
   - Made the rule easier to find and reference

This experience directly informed and validated this rule's creation.
