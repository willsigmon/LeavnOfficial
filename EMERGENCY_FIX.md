# Emergency Fix for libdispatch Assertion Failure

## Root Cause
The crash is caused by a dispatch queue assertion failure. This happens when code expects to run on a specific queue but is executed on a different one.

## Immediate Actions

1. **Clean and Rebuild**
   ```bash
   rm -rf ~/Library/Developer/Xcode/DerivedData/Leavn-*
   ```

2. **Key Fix Applied**
   - Fixed `PersistenceController` notification handlers to use `Task { @MainActor }` directly instead of `DispatchQueue.main.async` followed by Task

3. **Additional Checks Needed**
   - Verify all CoreData operations use proper contexts
   - Check if any third-party libraries have queue requirements
   - Ensure CloudKit operations are handled correctly

## Testing Steps

1. Launch app in Debug mode
2. Navigate to Bible tab
3. Switch between books slowly first
4. If stable, try rapid switching
5. Monitor console for any dispatch warnings

## If Still Crashing

The crash might be from:
- CloudKit framework internals
- CoreData automatic merging
- A third-party library with queue assertions

Try:
1. Disable CloudKit sync temporarily
2. Run with Zombie Objects enabled
3. Add symbolic breakpoint for `_dispatch_assert_queue_fail`