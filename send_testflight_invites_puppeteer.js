#!/usr/bin/env node

const fs = require('fs');
const readline = require('readline');

// Read emails from testflight_emails.txt
async function readEmails() {
    const emails = [];
    const fileStream = fs.createReadStream('testflight_emails.txt');
    const rl = readline.createInterface({
        input: fileStream,
        crlfDelay: Infinity
    });
    
    for await (const line of rl) {
        const email = line.trim();
        if (email && email.includes('@')) {
            emails.push(email);
        }
    }
    
    return emails;
}

// Main function
async function main() {
    console.log('📧 Reading emails from testflight_emails.txt...');
    
    try {
        const emails = await readEmails();
        console.log(`✅ Found ${emails.length} email addresses to invite\n`);
        
        console.log('🌐 Opening App Store Connect...');
        console.log('Please use the MCP Puppeteer tool to:\n');
        
        console.log('1. Navigate to App Store Connect:');
        console.log('   puppeteer_navigate url="https://appstoreconnect.apple.com"');
        
        console.log('\n2. Sign in with your Apple ID');
        
        console.log('\n3. Navigate to your app\'s TestFlight page:');
        console.log('   - Click on "My Apps"');
        console.log('   - Select "Leavn"');
        console.log('   - Click on "TestFlight" tab');
        console.log('   - Click on "External Groups" or your testing group');
        
        console.log('\n4. Add testers by clicking "+" or "Add Testers"');
        
        console.log('\n5. Use these email addresses (copy and paste):');
        console.log('=' * 60);
        
        // Print emails in a format that can be easily copied
        console.log(emails.join('\n'));
        
        console.log('=' * 60);
        
        console.log('\n📋 Alternatively, here are the emails in comma-separated format:');
        console.log(emails.join(', '));
        
        console.log('\n💡 Tips:');
        console.log('- App Store Connect allows bulk adding by pasting multiple emails');
        console.log('- Emails can be separated by commas, semicolons, or new lines');
        console.log('- Maximum 10,000 external testers per app');
        
    } catch (error) {
        console.error('❌ Error reading emails:', error.message);
        process.exit(1);
    }
}

// Run the script
main();
