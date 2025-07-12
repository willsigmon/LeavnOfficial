#!/bin/bash
# Verify all import statements using grep

echo "🔍 Verifying import statements..."

# Check for any incorrect imports
echo "=== Checking for incorrect LeavnServices imports ==="
find . -name "*.swift" -type f | xargs grep -E "import.*LeavnService[^s]|import.*Leavn Service|import.*LeavServices" 2>/dev/null || echo "✅ No incorrect imports found"

echo -e "\n=== All LeavnServices imports ==="
find . -name "*.swift" -type f | xargs grep -l "import LeavnServices" 2>/dev/null | sort | wc -l | xargs echo "Files with LeavnServices imports:"
find . -name "*.swift" -type f | xargs grep -l "import LeavnServices" 2>/dev/null | sort

echo -e "\n=== All LeavnCore imports ==="
find . -name "*.swift" -type f | xargs grep -l "import LeavnCore" 2>/dev/null | sort | wc -l | xargs echo "Files with LeavnCore imports:"
find . -name "*.swift" -type f | xargs grep -l "import LeavnCore" 2>/dev/null | sort | head -20

echo -e "\n=== Checking for circular imports ==="
# Check if LeavnCore imports any modules
cd local/LeavnCore 2>/dev/null && find . -name "*.swift" -type f | xargs grep -E "import Leavn(Bible|Search|Library|Settings|Community)" 2>/dev/null || echo "✅ No circular imports in LeavnCore"
cd ../..

echo -e "\n=== Sample imports from a module file ==="
# Show actual imports from a module file
if [ -f "local/LeavnModules/Bible/ViewModels/BibleViewModel.swift" ]; then
    echo "From BibleViewModel.swift:"
    head -10 "local/LeavnModules/Bible/ViewModels/BibleViewModel.swift" | grep "import" || echo "No imports in first 10 lines"
fi

echo -e "\n✅ Import verification complete!"