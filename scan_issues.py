#!/usr/bin/env python3
import os
import re
from pathlib import Path

def scan_swift_files(root_dir):
    issues = {
        'todos': [],
        'prints': [],
        'commented_code': []
    }
    
    swift_files = []
    for root, dirs, files in os.walk(root_dir):
        # Skip certain directories
        if any(skip in root for skip in ['.git', 'node_modules', '.build', 'DerivedData']):
            continue
        for file in files:
            if file.endswith('.swift'):
                swift_files.append(os.path.join(root, file))
    
    for file_path in swift_files:
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                lines = f.readlines()
                
            for line_num, line in enumerate(lines, 1):
                # Check for TODOs and FIXMEs
                if re.search(r'//\s*(TODO|FIXME)', line, re.IGNORECASE):
                    issues['todos'].append({
                        'file': file_path,
                        'line': line_num,
                        'content': line.strip()
                    })
                
                # Check for print statements (not in comments)
                if 'print(' in line and not line.strip().startswith('//'):
                    # Check if it's in a comment block
                    if not (line_num > 1 and '/*' in ''.join(lines[:line_num-1]) and '*/' not in ''.join(lines[:line_num])):
                        issues['prints'].append({
                            'file': file_path,
                            'line': line_num,
                            'content': line.strip()
                        })
                
                # Check for commented code (lines that look like Swift code but are commented)
                if line.strip().startswith('//') and len(line.strip()) > 2:
                    commented_part = line.strip()[2:].strip()
                    # Simple heuristics for Swift code
                    if any(pattern in commented_part for pattern in ['let ', 'var ', 'func ', 'class ', 'struct ', 'if ', 'for ', 'while ', '.sink', 'import ', '@', '= ']):
                        issues['commented_code'].append({
                            'file': file_path,
                            'line': line_num,
                            'content': line.strip()
                        })
                        
        except Exception as e:
            print(f"Error reading {file_path}: {e}")
    
    return issues, swift_files

def main():
    root_dir = '/Users/wsig/Cursor Repos/LeavnOfficial'
    print(f"Scanning Swift files in {root_dir}...")
    
    issues, swift_files = scan_swift_files(root_dir)
    
    print(f"\nTotal Swift files scanned: {len(swift_files)}")
    print(f"\nTODO/FIXME comments found: {len(issues['todos'])}")
    print(f"Print statements found: {len(issues['prints'])}")
    print(f"Commented code blocks found: {len(issues['commented_code'])}")
    
    # Write detailed report
    with open('/Users/wsig/Cursor Repos/LeavnOfficial/cleanup_report.txt', 'w') as f:
        f.write("=== CODE CLEANUP REPORT ===\n\n")
        
        f.write(f"Total Swift files scanned: {len(swift_files)}\n\n")
        
        f.write("=== TODO/FIXME COMMENTS ===\n")
        for issue in issues['todos']:
            f.write(f"\n{issue['file']}:{issue['line']}\n")
            f.write(f"  {issue['content']}\n")
        
        f.write("\n\n=== PRINT STATEMENTS ===\n")
        for issue in issues['prints']:
            f.write(f"\n{issue['file']}:{issue['line']}\n")
            f.write(f"  {issue['content']}\n")
        
        f.write("\n\n=== COMMENTED CODE ===\n")
        for issue in issues['commented_code'][:50]:  # Limit to first 50 to avoid huge report
            f.write(f"\n{issue['file']}:{issue['line']}\n")
            f.write(f"  {issue['content']}\n")
        
        if len(issues['commented_code']) > 50:
            f.write(f"\n... and {len(issues['commented_code']) - 50} more commented code blocks\n")
    
    print("\nDetailed report written to cleanup_report.txt")
    
    # Return the issues for processing
    return issues

if __name__ == "__main__":
    main()