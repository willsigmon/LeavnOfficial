#!/bin/bash
# Safe Xcode launch for beta versions

echo "🚀 Launching Xcode with beta-safe settings..."

# Set environment variables for stability
export XCODE_DISABLE_AUTOMATIC_SCHEME_CREATION=1
export SWIFT_DETERMINISTIC_HASHING=1
export MALLOC_SCRIBBLE=1

# Launch with reduced functionality for stability
open -a "Xcode-beta" --args -UseModernBuildSystem=YES -DisableDocumentVersioning=YES

echo "✅ Xcode launched with stability settings"
