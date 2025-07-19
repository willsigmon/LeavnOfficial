# Contributing to Leavn Super Official

Thank you for your interest in contributing to Leavn! We're excited to work with the community to make Bible study more accessible and meaningful.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [How Can I Contribute?](#how-can-i-contribute)
- [Development Process](#development-process)
- [Style Guidelines](#style-guidelines)
- [Commit Guidelines](#commit-guidelines)
- [Pull Request Process](#pull-request-process)
- [Community](#community)

## Code of Conduct

### Our Pledge

We are committed to making participation in this project a welcoming and respectful experience for everyone, regardless of background, identity, or experience level.

### Expected Behavior

- Use welcoming and inclusive language
- Be respectful of differing viewpoints
- Gracefully accept constructive criticism
- Focus on what is best for the community
- Show empathy towards other community members

### Unacceptable Behavior

- Harassment, discrimination, or hate speech
- Trolling, insulting/derogatory comments
- Public or private harassment
- Publishing others' private information
- Other conduct deemed inappropriate

## How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check existing issues to avoid duplicates.

**To submit a bug report:**

1. Use the issue template
2. Include a clear title and description
3. Provide steps to reproduce
4. Include device/OS information
5. Add screenshots if applicable
6. Describe expected vs actual behavior

**Good bug report example:**
```markdown
**Title**: Audio playback stops when app backgrounds

**Description**: When playing audio narration and switching to another app, 
playback stops after ~30 seconds.

**Steps to Reproduce**:
1. Start audio playback for any chapter
2. Switch to another app
3. Wait 30 seconds
4. Audio stops

**Expected**: Audio continues playing in background
**Actual**: Audio stops after 30 seconds

**Environment**:
- iOS Version: 18.0
- Device: iPhone 15 Pro
- App Version: 1.0.0 (Build 42)
```

### Suggesting Enhancements

We love feature suggestions! Please:

1. Check if already suggested
2. Create detailed proposal
3. Explain the use case
4. Consider implementation
5. Be open to feedback

**Feature request template:**
```markdown
**Feature**: Reading plan templates

**Use Case**: Users want pre-made reading plans for common goals
(Read Bible in a year, Gospels in 40 days, etc.)

**Proposed Implementation**:
- New "Plans" section in Library
- Template selection screen
- Progress tracking
- Reminder notifications

**Benefits**:
- Increased engagement
- Structured reading
- Achievement motivation
```

### Beta Testing

Join our TestFlight beta:

1. Email beta@leavn.app
2. Include your Apple ID email
3. Specify device types
4. Areas of interest for testing
5. Accept TestFlight invitation

**Effective beta feedback includes:**
- Specific issues encountered
- Steps to reproduce
- Screenshots/recordings
- Device and iOS version
- Severity assessment

### Documentation

Help improve our docs:

- Fix typos and grammar
- Clarify confusing sections
- Add missing information
- Improve code examples
- Translate documentation

### Code Contributions

Currently, the codebase is private, but we plan to open source components. When available:

1. Fork the repository
2. Create feature branch
3. Make your changes
4. Write/update tests
5. Submit pull request

## Development Process

### 1. Setting Up Development Environment

See [Development Setup Guide](docs/DEVELOPMENT_SETUP.md) for detailed instructions.

**Quick start:**
```bash
# Clone repository
git clone https://github.com/yourusername/LeavnSuperOfficial.git
cd LeavnSuperOfficial

# Open in Xcode
open Package.swift

# Run tests
swift test
```

### 2. Development Workflow

```
main
  ├── develop (integration branch)
  │   ├── feature/audio-speed-control
  │   ├── feature/offline-search
  │   └── bugfix/crash-on-launch
  └── release/1.1.0
```

### 3. Testing Requirements

- Write unit tests for new features
- Maintain >80% code coverage
- Run all tests before submitting
- Include UI tests for critical paths

## Style Guidelines

### Swift Style Guide

We follow the [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/) with these specifics:

#### Naming
```swift
// ✅ Good: Clear, descriptive names
func loadBiblePassage(book: Book, chapter: Int) async throws -> [Verse]

// ❌ Bad: Unclear abbreviations
func ldPsg(b: Book, c: Int) async throws -> [Verse]
```

#### Organization
```swift
// MARK: - Properties
private let apiClient: ESVClient
@Published var verses: [Verse] = []

// MARK: - Lifecycle
init(apiClient: ESVClient) {
    self.apiClient = apiClient
}

// MARK: - Public Methods
func loadChapter(_ chapter: Int) async {
    // Implementation
}

// MARK: - Private Methods
private func parseResponse(_ data: Data) -> [Verse] {
    // Implementation
}
```

#### SwiftUI Best Practices
```swift
struct BibleReaderView: View {
    @StateObject private var viewModel: BibleReaderViewModel
    
    var body: some View {
        // Prefer computed properties for complex views
        content
            .navigationTitle("Bible")
            .toolbar { toolbarContent }
    }
    
    @ViewBuilder
    private var content: some View {
        // Main content
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        // Toolbar items
    }
}
```

### Documentation

Use clear, concise documentation:

```swift
/// Loads Bible verses for the specified reference.
/// - Parameters:
///   - book: The Bible book to load
///   - chapter: Chapter number (1-based)
///   - verse: Optional specific verse (nil loads entire chapter)
/// - Returns: Array of verses for the reference
/// - Throws: `APIError` if the request fails
func loadVerses(
    book: Book,
    chapter: Int,
    verse: Int? = nil
) async throws -> [Verse]
```

## Commit Guidelines

We use [Conventional Commits](https://www.conventionalcommits.org/):

### Format
```
<type>(<scope>): <subject>

<body>

<footer>
```

### Types
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation only
- `style`: Code style (formatting, semicolons, etc)
- `refactor`: Code restructuring
- `perf`: Performance improvements
- `test`: Adding tests
- `chore`: Maintenance tasks

### Examples
```bash
# Feature
feat(audio): add playback speed control

# Bug fix
fix(bible): prevent crash when chapter has no verses

# Documentation
docs(api): update ESV integration guide

# Refactor
refactor(community): extract prayer wall into separate module
```

### Commit Message Guidelines

1. Use present tense ("add feature" not "added feature")
2. Use imperative mood ("move cursor" not "moves cursor")
3. Limit first line to 72 characters
4. Reference issues and pull requests

## Pull Request Process

### Before Submitting

- [ ] Tests pass locally
- [ ] Code follows style guide
- [ ] Documentation updated
- [ ] Commit messages follow convention
- [ ] Branch is up to date with main

### PR Template

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing
- [ ] Unit tests pass
- [ ] UI tests pass
- [ ] Manual testing completed

## Screenshots
(If applicable)

## Related Issues
Fixes #123
```

### Review Process

1. **Automated checks** must pass
2. **Code review** by maintainers
3. **Testing** on multiple devices
4. **Documentation** review
5. **Final approval** and merge

### What to Expect

- Initial response within 48 hours
- Constructive feedback
- Possible revision requests
- Recognition for your contribution

## Community

### Communication Channels

- **GitHub Issues**: Bug reports and features
- **Email**: contribute@leavn.app
- **TestFlight**: Beta testing feedback
- **Twitter**: @LeavnApp (coming soon)

### Getting Help

- Check documentation first
- Search existing issues
- Ask clear, specific questions
- Provide context and examples

### Recognition

Contributors are recognized in:
- Release notes
- Contributors file
- App credits
- Annual contributor spotlight

## License

By contributing, you agree that your contributions will be licensed under the same license as the project.

---

Thank you for contributing to Leavn! Together, we're making Bible study more accessible and meaningful for everyone.