#!/bin/bash
# Verify all import statements are correct

echo "🔍 Verifying import statements..."

# Check for any incorrect imports
echo "=== Checking for incorrect LeavnServices imports ==="
rg "import.*LeavnService[^s]|import.*Leavn Service|import.*LeavServices" --type swift || echo "✅ No incorrect imports found"

echo -e "\n=== All LeavnServices imports ==="
rg "import LeavnServices" --type swift -c | sort

echo -e "\n=== All LeavnCore imports ==="
rg "import LeavnCore" --type swift -c | sort

echo -e "\n=== Checking for circular imports ==="
# Check if LeavnCore imports any modules
rg "import Leavn(Bible|Search|Library|Settings|Community)" local/LeavnCore --type swift || echo "✅ No circular imports in LeavnCore"

echo -e "\n✅ Import verification complete!"