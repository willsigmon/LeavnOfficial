#!/bin/bash

# Resolve Swift Package Manager dependencies

echo "Resolving LeavnCore package dependencies..."
cd Core/LeavnCore
swift package resolve

echo "Resolving LeavnModules package dependencies..."
cd ../LeavnModules
swift package resolve

echo "Package resolution complete."