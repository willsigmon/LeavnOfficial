#!/bin/bash
# Environment Setup Script for LeavnSuperOfficial

set -e

# Configuration
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
ENV_FILE="$PROJECT_DIR/.env"
ENV_EXAMPLE="$PROJECT_DIR/.env.example"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Function to print colored output
print_message() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# Function to prompt for input with default
prompt_with_default() {
    local prompt=$1
    local default=$2
    local var_name=$3
    
    read -p "$prompt [$default]: " input
    local value="${input:-$default}"
    echo "$var_name=$value"
}

# Create .env.example if it doesn't exist
create_env_example() {
    cat > "$ENV_EXAMPLE" << 'EOF'
# LeavnSuperOfficial Environment Configuration
# Copy this file to .env and fill in your values

# App Configuration
APP_BUNDLE_ID=com.leavn.superofficial
APP_NAME=Leavn
ENVIRONMENT=development

# API Keys
ESV_API_KEY=your_esv_api_key_here
ELEVENLABS_API_KEY=your_elevenlabs_api_key_here
OPENAI_API_KEY=your_openai_api_key_here

# Backend Configuration
API_BASE_URL=https://api.leavn.app
WEBSOCKET_URL=wss://ws.leavn.app

# Feature Flags
ENABLE_ANALYTICS=false
ENABLE_CRASH_REPORTING=false
ENABLE_REMOTE_CONFIG=false
ENABLE_DEBUG_MENU=true

# TestFlight Configuration
TESTFLIGHT_APP_ID=your_app_id_here
TESTFLIGHT_BETA_GROUP=Beta Testers

# App Store Connect
ASC_API_KEY_ID=your_key_id_here
ASC_API_ISSUER_ID=your_issuer_id_here
ASC_API_KEY_PATH=~/.private_keys/AuthKey_YOUR_KEY_ID.p8

# Code Signing
MATCH_GIT_URL=git@github.com:YourOrg/certificates.git
MATCH_PASSWORD=your_match_password_here
TEAM_ID=your_team_id_here

# CI/CD
SLACK_WEBHOOK_URL=https://hooks.slack.com/services/YOUR/WEBHOOK/URL
GITHUB_TOKEN=your_github_token_here

# Analytics
FIREBASE_APP_ID=your_firebase_app_id_here
AMPLITUDE_API_KEY=your_amplitude_key_here
MIXPANEL_TOKEN=your_mixpanel_token_here

# Crash Reporting
BUGSNAG_API_KEY=your_bugsnag_key_here
SENTRY_DSN=your_sentry_dsn_here

# Performance Monitoring
NEW_RELIC_APP_TOKEN=your_new_relic_token_here

# Build Settings
XCODE_VERSION=15.0
IOS_DEPLOYMENT_TARGET=16.0
SWIFT_VERSION=5.9

# Debug Settings
DEBUG_MENU_PASSWORD=debug123
VERBOSE_LOGGING=false
NETWORK_LOGGING=false
EOF
    
    print_message $GREEN "Created .env.example file"
}

# Setup environment file
setup_env_file() {
    if [ -f "$ENV_FILE" ]; then
        print_message $YELLOW ".env file already exists. Backing up to .env.backup"
        cp "$ENV_FILE" "$ENV_FILE.backup"
    fi
    
    print_message $BLUE "Setting up environment configuration..."
    echo ""
    
    # Create new .env file
    cat > "$ENV_FILE" << EOF
# LeavnSuperOfficial Environment Configuration
# Generated on $(date)

# App Configuration
$(prompt_with_default "App Bundle ID" "com.leavn.superofficial" "APP_BUNDLE_ID")
$(prompt_with_default "App Name" "Leavn" "APP_NAME")
$(prompt_with_default "Environment" "development" "ENVIRONMENT")

# API Keys (Leave empty if you don't have them yet)
$(prompt_with_default "ESV API Key" "" "ESV_API_KEY")
$(prompt_with_default "ElevenLabs API Key" "" "ELEVENLABS_API_KEY")
$(prompt_with_default "OpenAI API Key" "" "OPENAI_API_KEY")

# Backend Configuration
$(prompt_with_default "API Base URL" "https://api.leavn.app" "API_BASE_URL")
$(prompt_with_default "WebSocket URL" "wss://ws.leavn.app" "WEBSOCKET_URL")

# Feature Flags
ENABLE_ANALYTICS=false
ENABLE_CRASH_REPORTING=false
ENABLE_REMOTE_CONFIG=false
ENABLE_DEBUG_MENU=true

# Build Settings
XCODE_VERSION=$(/usr/bin/xcodebuild -version | head -1 | awk '{print $2}')
IOS_DEPLOYMENT_TARGET=16.0
SWIFT_VERSION=5.9
EOF
    
    print_message $GREEN "Environment file created successfully!"
}

# Setup Git hooks
setup_git_hooks() {
    print_message $YELLOW "Setting up Git hooks..."
    
    local hooks_dir="$PROJECT_DIR/.git/hooks"
    
    # Pre-commit hook
    cat > "$hooks_dir/pre-commit" << 'EOF'
#!/bin/bash
# Pre-commit hook for LeavnSuperOfficial

# Run SwiftLint
if which swiftlint >/dev/null; then
    echo "Running SwiftLint..."
    swiftlint lint --quiet --config .swiftlint.yml
else
    echo "warning: SwiftLint not installed, download from https://github.com/realm/SwiftLint"
fi

# Check for large files
find . -type f -size +10M | grep -v ".git" | while read file; do
    echo "Error: Large file detected: $file"
    echo "Please use Git LFS for files larger than 10MB"
    exit 1
done

# Check for sensitive data
if git diff --cached --name-only | xargs grep -E "(password|secret|key|token)\\s*=\\s*[\"'][^\"']+[\"']" 2>/dev/null; then
    echo "Error: Possible hardcoded credentials detected"
    echo "Please use environment variables for sensitive data"
    exit 1
fi
EOF
    
    chmod +x "$hooks_dir/pre-commit"
    
    # Pre-push hook
    cat > "$hooks_dir/pre-push" << 'EOF'
#!/bin/bash
# Pre-push hook for LeavnSuperOfficial

# Run tests before pushing
echo "Running tests..."
xcodebuild test -scheme LeavnSuperOfficial -destination "platform=iOS Simulator,name=iPhone 15" -quiet

if [ $? -ne 0 ]; then
    echo "Tests failed. Push aborted."
    exit 1
fi

echo "All tests passed!"
EOF
    
    chmod +x "$hooks_dir/pre-push"
    
    print_message $GREEN "Git hooks installed successfully!"
}

# Install dependencies
install_dependencies() {
    print_message $YELLOW "Installing dependencies..."
    
    # Check for Homebrew
    if ! command -v brew &> /dev/null; then
        print_message $RED "Homebrew not found. Please install Homebrew first."
        exit 1
    fi
    
    # Install required tools
    local tools=("swiftlint" "fastlane" "cocoapods" "xcpretty" "pngquant" "jpegoptim")
    
    for tool in "${tools[@]}"; do
        if ! command -v "$tool" &> /dev/null; then
            print_message $BLUE "Installing $tool..."
            brew install "$tool"
        else
            print_message $GREEN "✓ $tool already installed"
        fi
    done
    
    # Install Ruby gems
    print_message $BLUE "Installing Ruby gems..."
    gem install bundler
    
    # Create Gemfile if it doesn't exist
    if [ ! -f "$PROJECT_DIR/Gemfile" ]; then
        cat > "$PROJECT_DIR/Gemfile" << 'EOF'
source "https://rubygems.org"

gem "fastlane"
gem "cocoapods"
gem "xcpretty"
gem "danger"
gem "danger-swiftlint"
gem "xcov"
EOF
    fi
    
    bundle install
}

# Main setup function
main() {
    print_message $BLUE "🚀 LeavnSuperOfficial Environment Setup"
    print_message $BLUE "========================================"
    echo ""
    
    # Create .env.example
    if [ ! -f "$ENV_EXAMPLE" ]; then
        create_env_example
    fi
    
    # Setup based on arguments
    case "${1:-all}" in
        env)
            setup_env_file
            ;;
        hooks)
            setup_git_hooks
            ;;
        deps)
            install_dependencies
            ;;
        all)
            setup_env_file
            setup_git_hooks
            install_dependencies
            ;;
        *)
            echo "Usage: $0 [all|env|hooks|deps]"
            exit 1
            ;;
    esac
    
    echo ""
    print_message $GREEN "✅ Setup complete!"
    print_message $YELLOW "Next steps:"
    print_message $YELLOW "1. Review and update .env file with your actual values"
    print_message $YELLOW "2. Run 'fastlane setup' to configure code signing"
    print_message $YELLOW "3. Run 'fastlane test' to verify everything is working"
}

# Run main function
main "$@"