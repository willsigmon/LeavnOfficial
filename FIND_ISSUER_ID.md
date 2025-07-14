# How to Find Your App Store Connect Issuer ID

The Issuer ID is required for API authentication. Here's how to find it:

## Steps to Find Your Issuer ID:

1. **Go to App Store Connect**
   - Visit: https://appstoreconnect.apple.com
   - Sign in with your Apple Developer account

2. **Navigate to Users and Access**
   - Click on "Users and Access" in the top navigation bar

3. **Go to Keys Tab**
   - Click on the "Keys" tab (you might need to scroll right to see it)
   - Or directly visit: https://appstoreconnect.apple.com/access/api

4. **Find Your Issuer ID**
   - At the top of the API Keys page, you'll see a section that shows:
     - **Issuer ID**: (This will be a UUID like `69a6de70-03db-47e3-8b3f-3d86fcb4d8a0`)
   - Copy this entire ID

## What the Issuer ID Looks Like:
- Format: `XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX`
- Example: `69a6de70-03db-47e3-8b3f-3d86fcb4d8a0`
- It's a standard UUID format with dashes

## Important Notes:
- The Issuer ID is the same for all API keys in your team
- It's different from the Key ID (which you already have: 4977S9H36P)
- You need both the Issuer ID and Key ID for authentication

## Once You Have It:
Run the setup script again with the correct Issuer ID:
```bash
./setup_api_credentials.sh
```

When prompted:
- API Key ID: 4977S9H36P (keep this the same)
- Issuer ID: [paste the UUID you found]
