#!/bin/bash

# 1Password Premium Extract Script
echo "🔐 1Password Premium Extractor"
echo "=============================="

INPUT_FILE="/Users/wsig/1PasswordExport-WFBT6KGBPVCE5JY4NWRMTSF7GE-20250709-001423.1pux"
OUTPUT_DIR="/Users/wsig/Cursor Repos/LeavnOfficial"

# Create extract directory
mkdir -p "$OUTPUT_DIR/1p_extract"

# Extract the 1pux file (it's a zip file)
cd "$OUTPUT_DIR"
unzip -q "$INPUT_FILE" -d 1p_extract/

# Check what was extracted
echo "📁 Extracted files:"
ls -la 1p_extract/

# Look for data files
echo ""
echo "🔍 Looking for data files..."
find 1p_extract/ -name "*.json" -type f | head -5

# Preview the main data file
echo ""
echo "📄 Data file preview:"
DATA_FILE=$(find 1p_extract/ -name "*.json" -type f | head -1)
if [ -f "$DATA_FILE" ]; then
    echo "Found: $DATA_FILE"
    head -20 "$DATA_FILE"
else
    echo "No JSON data file found"
fi

# Create a simple HTML report
cat > passwords_simple.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>1Password Export</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .header { background: #007aff; color: white; padding: 20px; border-radius: 10px; }
        .item { background: #f5f5f5; margin: 10px 0; padding: 15px; border-radius: 8px; }
        .password { font-family: monospace; background: #e8e8e8; padding: 2px 6px; border-radius: 4px; }
    </style>
</head>
<body>
    <div class="header">
        <h1>🔐 1Password Export Report</h1>
        <p>Premium Password Manager Format</p>
    </div>
    
    <div class="stats">
        <h2>📊 Export Statistics</h2>
        <p>This is a premium export from your 1Password vault.</p>
    </div>
    
    <div class="instructions">
        <h2>🔧 Next Steps</h2>
        <ol>
            <li>The 1Password export has been extracted</li>
            <li>Check the JSON data file for your password entries</li>
            <li>You can import this data into Apple Passwords or other managers</li>
        </ol>
    </div>
</body>
</html>
EOF

echo ""
echo "✅ Basic extraction complete!"
echo "📁 Check the 1p_extract/ folder for your data"
echo "📄 passwords_simple.html created as a starting point"