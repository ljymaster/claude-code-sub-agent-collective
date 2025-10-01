# NPX Package Sync Issues - Critical Lessons

## Problem
Simple sync task between main project and NPX package took 10+ minutes with multiple version bumps due to missing obvious configuration points.

## Root Cause Analysis
The NPX installer has **THREE SEPARATE PLACES** where settings.json is configured:

1. **Template Files**
   - `templates/settings.json` 
   - `templates/settings.json.template`

2. **File Mapping System** 
   - `lib/file-mapping.js` - `getHookMapping()` function
   - `lib/file-mapping.js` - `getConfigMapping()` function

3. **Installer Logic**
   - `lib/installer.js` - `setupHooks()` hardcoded array
   - `lib/installer.js` - `configureSettings()` hardcoded object

## What Went Wrong
- Only checked and updated template files initially
- Missed that `setupHooks()` had hardcoded hook list missing `load-behavioral-system.sh`
- Missed that `configureSettings()` had hardcoded settings object missing SessionStart hooks
- Each miss required another version bump (1.0.14 → 1.0.19)

## Proper Sync Checklist
When updating NPX package configuration, check ALL these locations:

### 1. Template Files
- [ ] `templates/settings.json`
- [ ] `templates/settings.json.template`

### 2. File Mapping Configuration  
- [ ] `lib/file-mapping.js` - `getHookMapping()` hook list
- [ ] `lib/file-mapping.js` - `getConfigMapping()` settings source

### 3. Installer Logic
- [ ] `lib/installer.js` - `setupHooks()` hardcoded hook array
- [ ] `lib/installer.js` - `configureSettings()` hardcoded settings object

### 4. Version Management
- [ ] `package.json` - version number
- [ ] Hook scripts - version display in output

## Prevention
1. **Consolidate configuration** - eliminate duplicate hardcoded lists
2. **Single source of truth** - use FileMapping system everywhere
3. **Automated sync** - script to sync main project to NPX templates
4. **Validation tests** - ensure installed package matches expected config

## Performance Impact
- 10+ minutes for basic sync
- 5 version bumps (1.0.14 → 1.0.19)  
- Multiple failed user tests
- Complete failure of systematic approach

## Never Again
This was inexcusable. A basic file sync should take 30 seconds, not 10+ minutes with multiple retries.