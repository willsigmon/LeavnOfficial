# CI/CD Pipeline Documentation for LeavnSuperOfficial

## Overview

This document describes the complete CI/CD pipeline setup for the LeavnSuperOfficial Bible app. The pipeline is designed for production-ready continuous deployment with comprehensive quality gates and automation.

## Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [GitHub Actions Workflows](#github-actions-workflows)
3. [Fastlane Configuration](#fastlane-configuration)
4. [Build Scripts](#build-scripts)
5. [Quality Gates](#quality-gates)
6. [Deployment Process](#deployment-process)
7. [Monitoring & Analytics](#monitoring--analytics)
8. [Security](#security)
9. [Troubleshooting](#troubleshooting)

## Architecture Overview

```
┌─────────────────┐     ┌──────────────┐     ┌─────────────┐
│   Developer     │────▶│    GitHub    │────▶│   CI/CD     │
│   Commits       │     │  Repository  │     │  Pipeline   │
└─────────────────┘     └──────────────┘     └─────────────┘
                                                     │
                                                     ▼
┌─────────────────┐     ┌──────────────┐     ┌─────────────┐
│   TestFlight    │◀────│   Fastlane   │◀────│   Tests &   │
│                 │     │              │     │   Checks    │
└─────────────────┘     └──────────────┘     └─────────────┘
                                                     │
                                                     ▼
┌─────────────────┐     ┌──────────────┐     ┌─────────────┐
│   App Store     │◀────│   Release    │◀────│  Quality    │
│                 │     │   Process    │     │   Gates     │
└─────────────────┘     └──────────────┘     └─────────────┘
```

## GitHub Actions Workflows

### 1. CI/CD Pipeline (`.github/workflows/ci.yml`)

**Triggers:**
- Push to `main` or `develop` branches
- Pull requests to `main`
- Manual workflow dispatch

**Jobs:**
- **Lint:** SwiftLint code style checking
- **Security Scan:** Vulnerability scanning with Trivy and dependency checks
- **Test:** Unit tests with code coverage
- **UI Test:** UI automation tests
- **Performance Test:** Performance benchmarks
- **Static Analysis:** Xcode static analyzer
- **Quality Gate:** Final validation check

### 2. Deployment Pipeline (`.github/workflows/deploy.yml`)

**Triggers:**
- Git tags matching `v*` pattern
- Manual workflow dispatch with lane selection

**Process:**
1. Setup signing certificates and provisioning profiles
2. Build release configuration
3. Upload to TestFlight
4. Generate and upload artifacts
5. Send notifications

### 3. PR Validation (`.github/workflows/pr-validation.yml`)

**Checks:**
- Semantic PR title validation
- Automatic PR labeling
- Large file detection
- Conventional commit format
- Danger CI for code review

### 4. Release Management (`.github/workflows/release.yml`)

**Features:**
- Automated changelog generation
- GitHub release creation
- Version management with Release Please
- Automatic deployment trigger

## Fastlane Configuration

### Available Lanes

#### Setup & Development
```bash
fastlane setup         # Setup development environment
fastlane build        # Build for testing
fastlane test         # Run all tests with coverage
fastlane ui_test      # Run UI tests only
fastlane performance_test # Run performance tests
```

#### Deployment
```bash
fastlane beta         # Deploy to TestFlight
fastlane release      # Deploy to App Store
fastlane screenshots  # Generate App Store screenshots
fastlane deliver_metadata # Update App Store metadata
```

#### Utilities
```bash
fastlane validate     # Validate before submission
fastlane create_release # Create GitHub release
fastlane rollback version:1.2.3 # Emergency rollback
```

### Configuration Files

- **Fastfile:** Main automation configuration
- **Appfile:** App-specific settings
- **Matchfile:** Code signing configuration
- **Deliverfile:** App Store metadata configuration
- **Scanfile:** Test execution settings

## Build Scripts

### 1. Version Bump (`Scripts/CI/version-bump.sh`)

```bash
# Increment build number
./Scripts/CI/version-bump.sh build

# Bump version
./Scripts/CI/version-bump.sh major|minor|patch

# Set custom version
./Scripts/CI/version-bump.sh custom 2.0.0
```

### 2. Changelog Generator (`Scripts/CI/changelog-generator.sh`)

```bash
# Generate changelog
./Scripts/CI/changelog-generator.sh

# Output to custom file
./Scripts/CI/changelog-generator.sh RELEASE_NOTES.md
```

### 3. Asset Optimizer (`Scripts/CI/asset-optimizer.sh`)

```bash
# Optimize all assets
./Scripts/CI/asset-optimizer.sh optimize

# Validate assets only
./Scripts/CI/asset-optimizer.sh validate

# Generate app icons
./Scripts/CI/asset-optimizer.sh icons
```

### 4. Environment Setup (`Scripts/CI/environment-setup.sh`)

```bash
# Complete setup
./Scripts/CI/environment-setup.sh all

# Setup components individually
./Scripts/CI/environment-setup.sh env    # Environment file
./Scripts/CI/environment-setup.sh hooks  # Git hooks
./Scripts/CI/environment-setup.sh deps   # Dependencies
```

## Quality Gates

### Code Quality
- **SwiftLint:** Enforces Swift style and conventions
- **Code Coverage:** Minimum 70% coverage required
- **Static Analysis:** Xcode analyzer checks

### Security
- **Dependency Scanning:** Checks for known vulnerabilities
- **Secret Detection:** Prevents hardcoded credentials
- **Certificate Validation:** Ensures proper code signing

### Testing
- **Unit Tests:** Core functionality testing
- **UI Tests:** User interface automation
- **Performance Tests:** Benchmark critical paths
- **Snapshot Tests:** Visual regression testing

### Build Validation
- **Size Limits:** Monitors app binary size
- **Asset Optimization:** Ensures optimized images
- **Memory Leaks:** Detects potential memory issues

## Deployment Process

### Beta Deployment (TestFlight)

1. **Pre-flight Checks:**
   - Ensure on main branch
   - Verify clean git status
   - Run full test suite

2. **Build Process:**
   - Increment build number
   - Sync certificates with Match
   - Build release configuration

3. **Distribution:**
   - Upload to TestFlight
   - Notify beta testers
   - Generate release notes

4. **Post-deployment:**
   - Commit version bump
   - Create git tag
   - Push changes

### Production Release (App Store)

1. **Validation:**
   - Run all quality gates
   - Verify metadata
   - Check screenshots

2. **Submission:**
   - Build production IPA
   - Upload to App Store Connect
   - Submit for review (manual)

3. **Release:**
   - Monitor review status
   - Schedule phased release
   - Monitor crash reports

## Monitoring & Analytics

### Crash Reporting
- Integrate with Crashlytics/Bugsnag
- Monitor crash-free rate
- Set up alerts for spikes

### Performance Monitoring
- Track app launch time
- Monitor memory usage
- Analyze network requests

### User Analytics
- Track feature adoption
- Monitor user engagement
- Analyze conversion funnels

### Build Notifications
- Slack integration for build status
- Email notifications for failures
- GitHub status checks

## Security

### Code Signing
- Certificates stored in Match git repository
- Provisioning profiles auto-renewed
- App Store Connect API for authentication

### Secrets Management
- GitHub Secrets for sensitive data
- Environment variables for configuration
- Keychain for local development

### Security Scanning
- Automated vulnerability scanning
- Dependency updates
- Regular security audits

## Troubleshooting

### Common Issues

#### Build Failures
```bash
# Clear derived data
rm -rf ~/Library/Developer/Xcode/DerivedData

# Reset Fastlane
fastlane clean_build_artifacts

# Regenerate certificates
fastlane match nuke development
fastlane match development
```

#### Test Failures
```bash
# Run tests locally
fastlane test

# Debug specific test
xcodebuild test -scheme LeavnSuperOfficial -only-testing:TestTarget/TestCase
```

#### Deployment Issues
```bash
# Validate IPA
xcrun altool --validate-app -f app.ipa -t ios

# Check provisioning
security cms -D -i embedded.mobileprovision
```

### Debug Commands

```bash
# Check environment
fastlane env

# Verify certificates
fastlane match development --readonly

# Test notifications
fastlane run slack message:"Test"
```

## Best Practices

1. **Commit Messages:** Use conventional commits format
2. **Branch Protection:** Require PR reviews and passing tests
3. **Version Management:** Semantic versioning (MAJOR.MINOR.PATCH)
4. **Documentation:** Keep README and API docs updated
5. **Security:** Regular dependency updates and audits

## Getting Started

1. Clone the repository
2. Run `./Scripts/CI/environment-setup.sh all`
3. Configure secrets in `.env` file
4. Run `fastlane test` to verify setup
5. Create feature branch and start developing

For questions or issues, please contact the development team or create an issue in the repository.