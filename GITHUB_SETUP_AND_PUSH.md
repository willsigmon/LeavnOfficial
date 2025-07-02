# Complete GitHub Setup and Push Guide

## Step 1: Install Git (if needed)
```bash
# Check if git is installed
git --version

# If not installed, install via Homebrew
brew install git
```

## Step 2: Configure Git with Your Identity
```bash
git config --global user.name "Will Sigmon"
git config --global user.email "your-email@example.com"
```

## Step 3: GitHub Authentication Setup

### Option A: Personal Access Token (Recommended)
1. Go to GitHub.com → Settings → Developer settings → Personal access tokens → Tokens (classic)
2. Click "Generate new token (classic)"
3. Give it a name like "Leavn Development"
4. Select scopes: `repo` (full control of private repositories)
5. Click "Generate token"
6. **COPY THE TOKEN NOW** (you won't see it again!)

### Option B: SSH Key
```bash
# Generate SSH key
ssh-keygen -t ed25519 -C "your-email@example.com"

# Start ssh-agent
eval "$(ssh-agent -s)"

# Add SSH key to ssh-agent
ssh-add ~/.ssh/id_ed25519

# Copy SSH key to clipboard
pbcopy < ~/.ssh/id_ed25519.pub

# Add to GitHub: Settings → SSH and GPG keys → New SSH key
```

## Step 4: Initialize and Push Repository

```bash
# Navigate to your project
cd /Users/wsig/LeavnParent/Leavn

# Initialize git repository
git init

# Add .gitignore
cat > .gitignore << 'EOF'
# Xcode
*.xcuserstate
.DS_Store
build/
DerivedData/
*.xcodeproj/xcuserdata/
*.xcworkspace/xcuserdata/
*.xcodeproj/project.xcworkspace/xcuserdata/

# Swift Package Manager
.build/
.swiftpm/
Package.resolved

# CocoaPods
Pods/
*.xcworkspace

# Backup files
*.backup
*.bak
*~

# macOS
.DS_Store
.AppleDouble
.LSOverride

# Thumbnails
._*

# Files that might appear in the root of a volume
.DocumentRevisions-V100
.fseventsd
.Spotlight-V100
.TemporaryItems
.Trashes
.VolumeIcon.icns
.com.apple.timemachine.donotpresent
EOF

# Add all files
git add .

# Create initial commit
git commit -m "Initial commit: Leavn iOS app with real API integration

- Fixed all build issues and compilation errors
- Replaced mock data with real service calls
- Integrated GetBible API
- Modular architecture with LeavnCore and LeavnModules
- Support for iOS, macOS, watchOS, visionOS, tvOS"

# Create repository on GitHub first!
# Go to: https://github.com/new
# Repository name: LeavnOfficial
# Description: Beautiful Bible study app for iOS
# Private/Public: Your choice
# DO NOT initialize with README, .gitignore, or license
```

## Step 5: Connect and Push

### If using Personal Access Token:
```bash
# Add remote with token (replace YOUR_TOKEN with the token from Step 3)
git remote add origin https://YOUR_TOKEN@github.com/willsigmon/LeavnOfficial.git

# OR add remote without token (you'll be prompted for username/token)
git remote add origin https://github.com/willsigmon/LeavnOfficial.git

# Push to GitHub
git branch -M main
git push -u origin main
```

### If using SSH:
```bash
# Add remote with SSH
git remote add origin git@github.com:willsigmon/LeavnOfficial.git

# Push to GitHub
git branch -M main
git push -u origin main
```

## Step 6: Verify Success
- Go to https://github.com/willsigmon/LeavnOfficial
- You should see all your files

## Troubleshooting

### Authentication Failed?
```bash
# For token auth, update the remote URL with your token
git remote set-url origin https://YOUR_TOKEN@github.com/willsigmon/LeavnOfficial.git

# For SSH, ensure your key is added to ssh-agent
ssh-add -l
```

### Repository Already Exists?
```bash
# Remove the existing remote
git remote remove origin

# Add it again
git remote add origin https://github.com/willsigmon/LeavnOfficial.git
```

### Large Files Warning?
```bash
# If you get warnings about large files, you might need Git LFS
brew install git-lfs
git lfs install
git lfs track "*.zip"
git lfs track "*.framework"
git add .gitattributes
```

## Important Notes
- **NEVER** commit your Personal Access Token to the repository
- Store your token securely (use a password manager)
- For team collaboration, consider using SSH keys
- The token in the remote URL is only stored locally in your git config

## Quick Commands After Setup
```bash
# Check status
git status

# Add and commit changes
git add .
git commit -m "Your commit message"

# Push changes
git push

# Pull latest changes
git pull
```