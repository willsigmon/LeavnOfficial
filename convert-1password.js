#!/usr/bin/env node

const fs = require('fs');
const path = require('path');
const { promisify } = require('util');
const zlib = require('zlib');

// For extracting zip files
const AdmZip = require('adm-zip');

class OnePasswordConverter {
  constructor(exportPath) {
    this.exportPath = exportPath;
    this.entries = [];
  }

  async convert() {
    console.log('🔐 1Password to Premium Password Converter');
    console.log('=========================================\n');

    try {
      console.log('📦 Extracting 1Password export...');
      const zip = new AdmZip(this.exportPath);
      const zipEntries = zip.getEntries();

      // Look for data files
      let dataFound = false;
      for (const entry of zipEntries) {
        if (entry.entryName === 'data.json' || entry.entryName.endsWith('/data.json')) {
          console.log(`📄 Found data file: ${entry.entryName}`);
          const data = JSON.parse(entry.getData().toString('utf8'));
          this.parseData(data);
          dataFound = true;
          break;
        }
      }

      if (!dataFound) {
        // Try alternative format - look for export.json
        for (const entry of zipEntries) {
          if (entry.entryName.includes('.json')) {
            console.log(`📄 Found JSON file: ${entry.entryName}`);
            const content = entry.getData().toString('utf8');
            try {
              const data = JSON.parse(content);
              this.parseAlternativeFormat(data);
              dataFound = true;
              break;
            } catch (e) {
              console.log(`   ⚠️  Could not parse ${entry.entryName}`);
            }
          }
        }
      }

      if (!dataFound) {
        throw new Error('No data file found in 1Password export');
      }

      // Export to various formats
      await this.exportPremiumJSON();
      await this.exportPremiumCSV();
      await this.exportHTML();
      await this.exportAppleKeychain();

      console.log('\n✅ Conversion complete!');
      console.log('\n📁 Generated files:');
      console.log('   • passwords_premium.json - Premium JSON format');
      console.log('   • passwords_premium.csv - Import-ready CSV');
      console.log('   • passwords_report.html - Visual report');
      console.log('   • passwords_keychain.csv - Apple Keychain format');

    } catch (error) {
      console.error('❌ Error:', error.message);
    }
  }

  parseData(data) {
    const items = data.items || [];
    console.log(`📊 Found ${items.length} password items`);

    for (const item of items) {
      const entry = {
        id: item.uuid || this.generateId(),
        title: item.title || 'Untitled',
        category: this.mapCategory(item.category),
        username: '',
        password: '',
        url: '',
        notes: item.notes || '',
        tags: item.tags || [],
        created: this.formatDate(item.createdAt),
        modified: this.formatDate(item.updatedAt),
        favorite: item.favorite || false,
        fields: [],
        attachments: (item.attachments || []).length,
        securityScore: 0,
        twoFactor: false
      };

      // Extract login fields
      if (item.fields) {
        for (const field of item.fields) {
          if (field.designation === 'username') {
            entry.username = field.value || '';
          } else if (field.designation === 'password') {
            entry.password = field.value || '';
            entry.securityScore = this.calculatePasswordScore(field.value);
          } else if (field.value) {
            entry.fields.push({
              name: field.name || field.designation || 'Field',
              value: field.value,
              type: field.type || 'text',
              concealed: field.concealed || false
            });
          }
        }
      }

      // Extract URLs
      if (item.urls && item.urls.length > 0) {
        entry.url = item.urls[0].url || item.urls[0].u || '';
      }

      // Check for 2FA
      if (item.sections) {
        for (const section of item.sections) {
          if (section.fields) {
            for (const field of section.fields) {
              if (field.k === 'one-time password' || field.n?.includes('OTP')) {
                entry.twoFactor = true;
              }
            }
          }
        }
      }

      this.entries.push(entry);
    }
  }

  parseAlternativeFormat(data) {
    // Handle different 1Password export formats
    if (Array.isArray(data)) {
      console.log(`📊 Found ${data.length} items in alternative format`);
      for (const item of data) {
        this.entries.push(this.convertAlternativeItem(item));
      }
    } else if (data.accounts) {
      // Handle account-based format
      for (const account of data.accounts) {
        if (account.vaults) {
          for (const vault of account.vaults) {
            if (vault.items) {
              for (const item of vault.items) {
                this.entries.push(this.convertAlternativeItem(item));
              }
            }
          }
        }
      }
    }
  }

  convertAlternativeItem(item) {
    return {
      id: item.id || item.uuid || this.generateId(),
      title: item.title || item.name || 'Untitled',
      category: this.mapCategory(item.category || item.type),
      username: item.username || item.login?.username || '',
      password: item.password || item.login?.password || '',
      url: item.url || item.website || '',
      notes: item.notes || '',
      tags: item.tags || [],
      created: this.formatDate(item.created || item.createdAt),
      modified: this.formatDate(item.modified || item.updatedAt),
      favorite: item.favorite || false,
      fields: [],
      attachments: 0,
      securityScore: this.calculatePasswordScore(item.password || ''),
      twoFactor: item.otpAuth ? true : false
    };
  }

  mapCategory(category) {
    const categoryMap = {
      'LOGIN': '🔐 Logins',
      'SECURE_NOTE': '📝 Secure Notes',
      'CREDIT_CARD': '💳 Payment Cards',
      'IDENTITY': '👤 Identities',
      'PASSWORD': '🔑 Passwords',
      'DOCUMENT': '📄 Documents',
      'SOFTWARE_LICENSE': '💿 Software',
      'BANK_ACCOUNT': '🏦 Banking',
      'DRIVER_LICENSE': '🚗 IDs',
      'PASSPORT': '✈️ Travel',
      'WIRELESS_ROUTER': '📡 Network',
      'SERVER': '🖥️ Servers',
      'EMAIL_ACCOUNT': '📧 Email',
      'API_CREDENTIAL': '🔌 API Keys'
    };
    return categoryMap[category] || '📦 Other';
  }

  calculatePasswordScore(password) {
    if (!password) return 0;
    
    let score = 0;
    if (password.length >= 12) score += 20;
    if (password.length >= 16) score += 20;
    if (/[a-z]/.test(password)) score += 10;
    if (/[A-Z]/.test(password)) score += 10;
    if (/[0-9]/.test(password)) score += 10;
    if (/[^A-Za-z0-9]/.test(password)) score += 20;
    if (password.length >= 20) score += 10;
    
    return score;
  }

  formatDate(timestamp) {
    if (!timestamp) return '';
    const date = new Date(timestamp);
    return date.toISOString().split('T')[0];
  }

  generateId() {
    return 'id_' + Date.now() + '_' + Math.random().toString(36).substr(2, 9);
  }

  async exportPremiumJSON() {
    const categoryStats = {};
    const securityStats = { excellent: 0, good: 0, fair: 0, weak: 0 };

    for (const entry of this.entries) {
      categoryStats[entry.category] = (categoryStats[entry.category] || 0) + 1;
      
      if (entry.securityScore >= 80) securityStats.excellent++;
      else if (entry.securityScore >= 60) securityStats.good++;
      else if (entry.securityScore >= 40) securityStats.fair++;
      else securityStats.weak++;
    }

    const exportData = {
      metadata: {
        version: '2.0',
        exported: new Date().toISOString(),
        source: '1Password',
        format: 'Premium Password Manager Export'
      },
      summary: {
        totalItems: this.entries.length,
        categories: categoryStats,
        security: securityStats,
        twoFactorEnabled: this.entries.filter(e => e.twoFactor).length
      },
      items: this.entries
    };

    await fs.promises.writeFile(
      path.join(process.cwd(), 'passwords_premium.json'),
      JSON.stringify(exportData, null, 2)
    );
  }

  async exportPremiumCSV() {
    const csv = [
      'Title,Category,Username,Password,URL,Notes,Tags,Security Score,2FA,Created,Modified'
    ];

    for (const entry of this.entries) {
      csv.push([
        this.escapeCSV(entry.title),
        this.escapeCSV(entry.category),
        this.escapeCSV(entry.username),
        this.escapeCSV(entry.password),
        this.escapeCSV(entry.url),
        this.escapeCSV(entry.notes),
        this.escapeCSV(entry.tags.join(', ')),
        entry.securityScore,
        entry.twoFactor ? 'Yes' : 'No',
        entry.created,
        entry.modified
      ].join(','));
    }

    await fs.promises.writeFile(
      path.join(process.cwd(), 'passwords_premium.csv'),
      csv.join('\n')
    );
  }

  async exportAppleKeychain() {
    const csv = [
      'Title,URL,Username,Password,Notes,OTPAuth'
    ];

    for (const entry of this.entries) {
      if (entry.category === '🔐 Logins') {
        csv.push([
          this.escapeCSV(entry.title),
          this.escapeCSV(entry.url),
          this.escapeCSV(entry.username),
          this.escapeCSV(entry.password),
          this.escapeCSV(entry.notes),
          '' // OTP field if available
        ].join(','));
      }
    }

    await fs.promises.writeFile(
      path.join(process.cwd(), 'passwords_keychain.csv'),
      csv.join('\n')
    );
  }

  async exportHTML() {
    const html = `<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Password Export Report</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'SF Pro Display', 'Segoe UI', sans-serif;
            background: linear-gradient(135deg, #1e3c72 0%, #2a5298 100%);
            min-height: 100vh;
            padding: 20px;
        }
        
        .container {
            max-width: 1400px;
            margin: 0 auto;
        }
        
        .header {
            text-align: center;
            color: white;
            margin-bottom: 40px;
        }
        
        .header h1 {
            font-size: 48px;
            font-weight: 300;
            margin-bottom: 10px;
            text-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        
        .header p {
            font-size: 18px;
            opacity: 0.9;
        }
        
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
            gap: 20px;
            margin-bottom: 40px;
        }
        
        .stat-card {
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(10px);
            border-radius: 20px;
            padding: 30px;
            text-align: center;
            box-shadow: 0 10px 30px rgba(0,0,0,0.1);
            transition: transform 0.3s ease, box-shadow 0.3s ease;
        }
        
        .stat-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 15px 40px rgba(0,0,0,0.15);
        }
        
        .stat-icon {
            font-size: 48px;
            margin-bottom: 15px;
        }
        
        .stat-value {
            font-size: 42px;
            font-weight: 600;
            color: #1e3c72;
            margin-bottom: 5px;
        }
        
        .stat-label {
            font-size: 16px;
            color: #666;
            font-weight: 500;
        }
        
        .content-card {
            background: rgba(255, 255, 255, 0.98);
            backdrop-filter: blur(10px);
            border-radius: 20px;
            padding: 40px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.1);
            margin-bottom: 30px;
        }
        
        .section-title {
            font-size: 28px;
            font-weight: 600;
            color: #1e3c72;
            margin-bottom: 25px;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        
        .category-chart {
            display: flex;
            flex-wrap: wrap;
            gap: 15px;
            margin-bottom: 30px;
        }
        
        .category-item {
            background: #f8f9fa;
            border-radius: 12px;
            padding: 15px 25px;
            display: flex;
            align-items: center;
            gap: 10px;
            transition: all 0.3s ease;
        }
        
        .category-item:hover {
            background: #e9ecef;
            transform: scale(1.05);
        }
        
        .category-count {
            font-size: 24px;
            font-weight: 600;
            color: #2a5298;
        }
        
        .security-meter {
            display: flex;
            gap: 10px;
            margin-bottom: 20px;
        }
        
        .security-segment {
            flex: 1;
            height: 40px;
            border-radius: 8px;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-weight: 600;
            transition: all 0.3s ease;
        }
        
        .security-segment:hover {
            transform: scale(1.05);
        }
        
        .security-excellent { background: #10b981; }
        .security-good { background: #3b82f6; }
        .security-fair { background: #f59e0b; }
        .security-weak { background: #ef4444; }
        
        .items-preview {
            margin-top: 30px;
        }
        
        .item-row {
            display: grid;
            grid-template-columns: 3fr 2fr 2fr 1fr;
            gap: 20px;
            padding: 20px;
            background: #f8f9fa;
            border-radius: 12px;
            margin-bottom: 10px;
            align-items: center;
            transition: all 0.3s ease;
        }
        
        .item-row:hover {
            background: #e9ecef;
            transform: translateX(5px);
        }
        
        .item-title {
            font-weight: 600;
            color: #1e3c72;
        }
        
        .item-category {
            display: inline-block;
            padding: 6px 12px;
            border-radius: 20px;
            font-size: 14px;
            background: #e3f2fd;
            color: #1565c0;
        }
        
        .security-badge {
            display: inline-block;
            padding: 6px 16px;
            border-radius: 20px;
            font-size: 14px;
            font-weight: 600;
            text-align: center;
        }
        
        .badge-excellent { background: #d1fae5; color: #065f46; }
        .badge-good { background: #dbeafe; color: #1e40af; }
        .badge-fair { background: #fed7aa; color: #92400e; }
        .badge-weak { background: #fee2e2; color: #991b1b; }
        
        .footer {
            text-align: center;
            color: white;
            margin-top: 40px;
            opacity: 0.8;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🔐 Password Export Report</h1>
            <p>Generated on ${new Date().toLocaleDateString('en-US', { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' })}</p>
        </div>
        
        <div class="stats-grid">
            <div class="stat-card">
                <div class="stat-icon">📊</div>
                <div class="stat-value">${this.entries.length}</div>
                <div class="stat-label">Total Passwords</div>
            </div>
            
            <div class="stat-card">
                <div class="stat-icon">🛡️</div>
                <div class="stat-value">${this.entries.filter(e => e.securityScore >= 80).length}</div>
                <div class="stat-label">Secure Passwords</div>
            </div>
            
            <div class="stat-card">
                <div class="stat-icon">🔐</div>
                <div class="stat-value">${this.entries.filter(e => e.twoFactor).length}</div>
                <div class="stat-label">2FA Enabled</div>
            </div>
            
            <div class="stat-card">
                <div class="stat-icon">⭐</div>
                <div class="stat-value">${this.entries.filter(e => e.favorite).length}</div>
                <div class="stat-label">Favorites</div>
            </div>
        </div>
        
        <div class="content-card">
            <h2 class="section-title">📁 Categories</h2>
            <div class="category-chart">
                ${this.generateCategoryHTML()}
            </div>
        </div>
        
        <div class="content-card">
            <h2 class="section-title">🛡️ Security Overview</h2>
            <div class="security-meter">
                ${this.generateSecurityHTML()}
            </div>
        </div>
        
        <div class="content-card">
            <h2 class="section-title">🔑 Recent Items</h2>
            <div class="items-preview">
                ${this.generateItemsHTML()}
            </div>
        </div>
        
        <div class="footer">
            <p>Exported from 1Password • Premium Password Manager Format</p>
        </div>
    </div>
</body>
</html>`;

    await fs.promises.writeFile(
      path.join(process.cwd(), 'passwords_report.html'),
      html
    );
  }

  generateCategoryHTML() {
    const categories = {};
    for (const entry of this.entries) {
      categories[entry.category] = (categories[entry.category] || 0) + 1;
    }
    
    return Object.entries(categories)
      .sort((a, b) => b[1] - a[1])
      .map(([cat, count]) => `
        <div class="category-item">
            <span>${cat}</span>
            <span class="category-count">${count}</span>
        </div>
      `).join('');
  }

  generateSecurityHTML() {
    const security = { excellent: 0, good: 0, fair: 0, weak: 0 };
    
    for (const entry of this.entries) {
      if (entry.securityScore >= 80) security.excellent++;
      else if (entry.securityScore >= 60) security.good++;
      else if (entry.securityScore >= 40) security.fair++;
      else security.weak++;
    }
    
    const total = this.entries.length || 1;
    
    return `
      <div class="security-segment security-excellent" style="flex: ${security.excellent}">
        ${Math.round(security.excellent / total * 100)}% Excellent
      </div>
      <div class="security-segment security-good" style="flex: ${security.good}">
        ${Math.round(security.good / total * 100)}% Good
      </div>
      <div class="security-segment security-fair" style="flex: ${security.fair}">
        ${Math.round(security.fair / total * 100)}% Fair
      </div>
      <div class="security-segment security-weak" style="flex: ${security.weak}">
        ${Math.round(security.weak / total * 100)}% Weak
      </div>
    `;
  }

  generateItemsHTML() {
    return this.entries
      .slice(0, 10)
      .map(entry => {
        let securityClass = 'weak';
        let securityText = 'Weak';
        
        if (entry.securityScore >= 80) {
          securityClass = 'excellent';
          securityText = 'Excellent';
        } else if (entry.securityScore >= 60) {
          securityClass = 'good';
          securityText = 'Good';
        } else if (entry.securityScore >= 40) {
          securityClass = 'fair';
          securityText = 'Fair';
        }
        
        return `
          <div class="item-row">
            <div class="item-title">${this.escapeHTML(entry.title)}</div>
            <div><span class="item-category">${entry.category}</span></div>
            <div>${this.escapeHTML(entry.username || 'No username')}</div>
            <div><span class="security-badge badge-${securityClass}">${securityText}</span></div>
          </div>
        `;
      }).join('');
  }

  escapeCSV(str) {
    if (!str) return '';
    if (str.includes(',') || str.includes('"') || str.includes('\n')) {
      return '"' + str.replace(/"/g, '""') + '"';
    }
    return str;
  }

  escapeHTML(str) {
    if (!str) return '';
    return str
      .replace(/&/g, '&amp;')
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;')
      .replace(/"/g, '&quot;')
      .replace(/'/g, '&#039;');
  }
}

// Check if adm-zip is installed
try {
  require.resolve('adm-zip');
} catch (e) {
  console.log('📦 Installing required dependencies...');
  const { execSync } = require('child_process');
  execSync('npm install adm-zip', { stdio: 'inherit' });
}

// Run the converter
const inputPath = '/Users/wsig/1PasswordExport-WFBT6KGBPVCE5JY4NWRMTSF7GE-20250709-001423.1pux';
const converter = new OnePasswordConverter(inputPath);
converter.convert();