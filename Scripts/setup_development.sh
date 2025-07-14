#!/bin/bash

# Development Setup Script for Leavn
# This script sets up the development environment

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print colored output
print_status() {
    echo -e "${GREEN}[SETUP]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

# Check system requirements
check_requirements() {
    print_status "Checking system requirements..."
    
    # Check for macOS
    if [[ "$OSTYPE" != "darwin"* ]]; then
        print_error "This script requires macOS"
        exit 1
    fi
    
    # Check for Xcode
    if ! xcode-select -p &> /dev/null; then
        print_error "Xcode is not installed. Please install Xcode from the App Store."
        exit 1
    fi
    
    # Check Xcode version
    XCODE_VERSION=$(xcodebuild -version | grep "Xcode" | cut -d' ' -f2)
    print_info "Xcode version: $XCODE_VERSION"
    
    # Check for Homebrew
    if ! command -v brew &> /dev/null; then
        print_warning "Homebrew not found. Installing..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
}

# Install development tools
install_tools() {
    print_status "Installing development tools..."
    
    # Update Homebrew
    brew update
    
    # Install tools via Homebrew
    brew_tools=(
        "xcbeautify"    # Better xcodebuild output
        "swiftlint"     # Swift linter
        "swift-format"  # Swift formatter
        "xcodegen"      # Generate Xcode projects
        "mint"          # Swift package manager for tools
    )
    
    for tool in "${brew_tools[@]}"; do
        if brew list "$tool" &> /dev/null; then
            print_info "$tool is already installed"
        else
            print_status "Installing $tool..."
            brew install "$tool"
        fi
    done
    
    # Install Ruby gems
    print_status "Installing Ruby gems..."
    gem install xcpretty --user-install
    gem install fastlane --user-install
}

# Setup project
setup_project() {
    print_status "Setting up project..."
    
    # Clean derived data
    print_status "Cleaning derived data..."
    rm -rf ~/Library/Developer/Xcode/DerivedData/Leavn-*
    
    # Resolve Swift packages
    print_status "Resolving Swift packages..."
    cd Core/LeavnCore
    swift package resolve
    cd ../..
    
    cd Core/LeavnModules
    swift package resolve
    cd ../..
    
    # Generate Xcode project if using XcodeGen
    if [ -f "project.yml" ]; then
        print_status "Generating Xcode project..."
        xcodegen generate
    fi
    
    # Create necessary directories
    print_status "Creating project directories..."
    mkdir -p Scripts
    mkdir -p TestResults
    mkdir -p .github/workflows
    
    # Make scripts executable
    print_status "Making scripts executable..."
    find Scripts -name "*.sh" -exec chmod +x {} \;
}

# Setup git hooks
setup_git_hooks() {
    print_status "Setting up git hooks..."
    
    # Create pre-commit hook for SwiftLint
    cat > .git/hooks/pre-commit << 'EOF'
#!/bin/bash
# Run SwiftLint before commit

if which swiftlint >/dev/null; then
    swiftlint lint --quiet
else
    echo "warning: SwiftLint not installed, download from https://github.com/realm/SwiftLint"
fi
EOF
    
    chmod +x .git/hooks/pre-commit
}

# Main execution
main() {
    print_status "🚀 Setting up Leavn development environment..."
    
    check_requirements
    install_tools
    setup_project
    
    # Only setup git hooks if .git exists
    if [ -d ".git" ]; then
        setup_git_hooks
    else
        print_warning "Git repository not found. Skipping git hooks setup."
    fi
    
    print_status "✅ Development environment setup complete!"
    print_info "You can now open Leavn.xcodeproj or Leavn.xcworkspace in Xcode"
    print_info "Run './Scripts/run_tests.sh' to run all tests"
    print_info "Run './Scripts/ci_build.sh' to build the project"
}

# Run the script
main