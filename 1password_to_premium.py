#!/usr/bin/env python3
"""
1Password to Premium Password App Converter
Converts 1Password export to a premium-looking format for password managers
"""

import json
import zipfile
import os
from datetime import datetime
from pathlib import Path
import csv

class OnePasswordConverter:
    def __init__(self, export_path):
        self.export_path = export_path
        self.entries = []
        
    def extract_data(self):
        """Extract and parse 1Password export data"""
        with zipfile.ZipFile(self.export_path, 'r') as zip_file:
            # Look for the data file
            for file_info in zip_file.filelist:
                if file_info.filename == 'data.json':
                    with zip_file.open(file_info) as data_file:
                        self.data = json.load(data_file)
                        break
                        
    def parse_items(self):
        """Parse items from 1Password data"""
        for item in self.data.get('items', []):
            entry = {
                'title': item.get('title', ''),
                'category': self._map_category(item.get('category', '')),
                'username': '',
                'password': '',
                'url': '',
                'notes': item.get('notes', ''),
                'created': self._format_date(item.get('created_at')),
                'modified': self._format_date(item.get('updated_at')),
                'tags': item.get('tags', []),
                'fields': [],
                'attachments': len(item.get('attachments', [])),
                'favorite': item.get('favorite', False),
                'security_level': self._calculate_security_level(item)
            }
            
            # Extract login details
            if 'fields' in item:
                for field in item['fields']:
                    if field.get('designation') == 'username':
                        entry['username'] = field.get('value', '')
                    elif field.get('designation') == 'password':
                        entry['password'] = field.get('value', '')
                    else:
                        entry['fields'].append({
                            'name': field.get('name', ''),
                            'value': field.get('value', ''),
                            'type': field.get('type', '')
                        })
                        
            # Extract URLs
            if 'urls' in item:
                urls = [url.get('u', '') for url in item.get('urls', [])]
                entry['url'] = urls[0] if urls else ''
                
            self.entries.append(entry)
            
    def _map_category(self, category):
        """Map 1Password categories to premium categories"""
        category_map = {
            'LOGIN': 'Logins',
            'SECURE_NOTE': 'Secure Notes',
            'CREDIT_CARD': 'Payment Cards',
            'IDENTITY': 'Identities',
            'PASSWORD': 'Passwords',
            'DOCUMENT': 'Documents',
            'SOFTWARE_LICENSE': 'Software',
            'BANK_ACCOUNT': 'Banking',
            'DRIVER_LICENSE': 'IDs',
            'PASSPORT': 'Travel',
            'WIRELESS_ROUTER': 'Network',
            'SERVER': 'Servers',
            'EMAIL_ACCOUNT': 'Email',
            'API_CREDENTIAL': 'API Keys'
        }
        return category_map.get(category, 'Other')
        
    def _format_date(self, timestamp):
        """Format timestamp to readable date"""
        if timestamp:
            try:
                dt = datetime.fromtimestamp(timestamp)
                return dt.strftime('%Y-%m-%d %H:%M:%S')
            except:
                pass
        return ''
        
    def _calculate_security_level(self, item):
        """Calculate security level based on password strength and 2FA"""
        # This would normally analyze password strength
        # For now, return a score based on field count
        score = 0
        if item.get('fields'):
            score += len(item['fields'])
        if item.get('otp'):
            score += 5
        if len(item.get('password', '')) > 16:
            score += 3
        
        if score >= 8:
            return 'Excellent'
        elif score >= 5:
            return 'Good'
        elif score >= 3:
            return 'Fair'
        else:
            return 'Weak'
            
    def export_premium_json(self, output_path):
        """Export to premium JSON format"""
        premium_data = {
            'version': '2.0',
            'exported_at': datetime.now().isoformat(),
            'source': '1Password',
            'statistics': {
                'total_items': len(self.entries),
                'categories': self._get_category_stats(),
                'security_summary': self._get_security_stats()
            },
            'items': self.entries
        }
        
        with open(output_path, 'w', encoding='utf-8') as f:
            json.dump(premium_data, f, indent=2, ensure_ascii=False)
            
    def export_premium_csv(self, output_path):
        """Export to premium CSV format"""
        with open(output_path, 'w', newline='', encoding='utf-8') as f:
            writer = csv.writer(f)
            writer.writerow([
                'Title', 'Category', 'Username', 'Password', 'URL', 
                'Notes', 'Tags', 'Created', 'Modified', 'Security Level'
            ])
            
            for entry in self.entries:
                writer.writerow([
                    entry['title'],
                    entry['category'],
                    entry['username'],
                    entry['password'],
                    entry['url'],
                    entry['notes'],
                    ', '.join(entry['tags']),
                    entry['created'],
                    entry['modified'],
                    entry['security_level']
                ])
                
    def _get_category_stats(self):
        """Get statistics by category"""
        stats = {}
        for entry in self.entries:
            cat = entry['category']
            stats[cat] = stats.get(cat, 0) + 1
        return stats
        
    def _get_security_stats(self):
        """Get security statistics"""
        stats = {'Excellent': 0, 'Good': 0, 'Fair': 0, 'Weak': 0}
        for entry in self.entries:
            level = entry['security_level']
            stats[level] = stats.get(level, 0) + 1
        return stats
        
    def generate_html_report(self, output_path):
        """Generate a premium HTML report"""
        html_template = '''
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Password Export Report</title>
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: #333;
            margin: 0;
            padding: 20px;
        }
        .container {
            max-width: 1200px;
            margin: 0 auto;
            background: white;
            border-radius: 20px;
            box-shadow: 0 20px 60px rgba(0,0,0,0.1);
            padding: 40px;
        }
        h1 {
            color: #667eea;
            text-align: center;
            margin-bottom: 40px;
        }
        .stats {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 20px;
            margin-bottom: 40px;
        }
        .stat-card {
            background: #f7fafc;
            border-radius: 10px;
            padding: 20px;
            text-align: center;
        }
        .stat-number {
            font-size: 36px;
            font-weight: bold;
            color: #667eea;
        }
        .stat-label {
            color: #718096;
            margin-top: 5px;
        }
        .items-table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
        }
        .items-table th {
            background: #667eea;
            color: white;
            padding: 12px;
            text-align: left;
        }
        .items-table td {
            padding: 12px;
            border-bottom: 1px solid #e2e8f0;
        }
        .items-table tr:hover {
            background: #f7fafc;
        }
        .category-badge {
            display: inline-block;
            padding: 4px 12px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 500;
        }
        .category-Logins { background: #bee3f8; color: #2c5282; }
        .category-Secure.Notes { background: #c6f6d5; color: #22543d; }
        .category-Payment.Cards { background: #fed7d7; color: #742a2a; }
        .security-Excellent { color: #22543d; }
        .security-Good { color: #2d3748; }
        .security-Fair { color: #d69e2e; }
        .security-Weak { color: #e53e3e; }
    </style>
</head>
<body>
    <div class="container">
        <h1>Password Export Report</h1>
        <div class="stats">
            <div class="stat-card">
                <div class="stat-number">{total_items}</div>
                <div class="stat-label">Total Items</div>
            </div>
            <div class="stat-card">
                <div class="stat-number">{categories}</div>
                <div class="stat-label">Categories</div>
            </div>
            <div class="stat-card">
                <div class="stat-number">{secure_items}</div>
                <div class="stat-label">Secure Items</div>
            </div>
        </div>
        
        <h2>Items Overview</h2>
        <table class="items-table">
            <thead>
                <tr>
                    <th>Title</th>
                    <th>Category</th>
                    <th>Username</th>
                    <th>Security</th>
                    <th>Created</th>
                </tr>
            </thead>
            <tbody>
                {items_rows}
            </tbody>
        </table>
    </div>
</body>
</html>
        '''
        
        # Generate table rows
        rows = []
        for entry in self.entries[:50]:  # Show first 50 items
            row = f'''
                <tr>
                    <td>{entry['title']}</td>
                    <td><span class="category-badge category-{entry['category'].replace(' ', '.')}">{entry['category']}</span></td>
                    <td>{entry['username']}</td>
                    <td class="security-{entry['security_level']}">{entry['security_level']}</td>
                    <td>{entry['created']}</td>
                </tr>
            '''
            rows.append(row)
            
        # Calculate statistics
        category_stats = self._get_category_stats()
        security_stats = self._get_security_stats()
        
        html = html_template.format(
            total_items=len(self.entries),
            categories=len(category_stats),
            secure_items=security_stats.get('Excellent', 0) + security_stats.get('Good', 0),
            items_rows=''.join(rows)
        )
        
        with open(output_path, 'w', encoding='utf-8') as f:
            f.write(html)


def main():
    # Input and output paths
    input_path = '/Users/wsig/1PasswordExport-WFBT6KGBPVCE5JY4NWRMTSF7GE-20250709-001423.1pux'
    output_dir = Path('/Users/wsig/Cursor Repos/LeavnOfficial')
    
    # Create converter
    converter = OnePasswordConverter(input_path)
    
    try:
        print("Extracting 1Password data...")
        converter.extract_data()
        
        print("Parsing items...")
        converter.parse_items()
        
        print(f"Found {len(converter.entries)} items")
        
        # Export in multiple formats
        print("Exporting to premium JSON format...")
        converter.export_premium_json(output_dir / 'passwords_premium.json')
        
        print("Exporting to premium CSV format...")
        converter.export_premium_csv(output_dir / 'passwords_premium.csv')
        
        print("Generating HTML report...")
        converter.generate_html_report(output_dir / 'passwords_report.html')
        
        print("\nExport complete!")
        print(f"Files created:")
        print(f"  - passwords_premium.json")
        print(f"  - passwords_premium.csv")
        print(f"  - passwords_report.html")
        
    except Exception as e:
        print(f"Error: {e}")
        print("The 1pux file might be in a different format. Let me analyze it...")
        
        # Try alternative parsing
        with zipfile.ZipFile(input_path, 'r') as zf:
            print("\nFiles in archive:")
            for name in zf.namelist():
                print(f"  - {name}")
                if name.endswith('.json'):
                    print(f"    Reading {name}...")
                    with zf.open(name) as f:
                        data = f.read(500)
                        print(f"    Preview: {data[:200]}...")


if __name__ == '__main__':
    main()