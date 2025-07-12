const { exec } = require('child_process');
const path = require('path');

const sourceIcon = '/Users/wsig/Library/Application Support/CleanShot/media/media_EtbRbqplnz/CleanShot 2025-07-12 at 04.13.28.png';
const destDir = '/Users/wsig/GitHub Builds/LeavnOfficial/Leavn/Assets.xcassets/AppIcon.appiconset';

const sizes = [
    { name: 'icon-20.png', size: '20x20' },
    { name: 'icon-20@2x.png', size: '40x40' },
    { name: 'icon-20@3x.png', size: '60x60' },
    { name: 'icon-29.png', size: '29x29' },
    { name: 'icon-29@2x.png', size: '58x58' },
    { name: 'icon-29@3x.png', size: '87x87' },
    { name: 'icon-40.png', size: '40x40' },
    { name: 'icon-40@2x.png', size: '80x80' },
    { name: 'icon-40@3x.png', size: '120x120' },
    { name: 'icon-60@2x.png', size: '120x120' },
    { name: 'icon-60@3x.png', size: '180x180' },
    { name: 'icon-76.png', size: '76x76' },
    { name: 'icon-76@2x.png', size: '152x152' },
    { name: 'icon-83.5@2x.png', size: '167x167' },
    { name: 'icon-1024.png', size: '1024x1024' }
];

console.log('Starting icon resize process...');

sizes.forEach(({ name, size }) => {
    const [width, height] = size.split('x');
    const outputPath = path.join(destDir, name);
    const command = `sips -z ${height} ${width} "${sourceIcon}" --out "${outputPath}"`;
    
    exec(command, (error, stdout, stderr) => {
        if (error) {
            console.error(`Error creating ${name}: ${error.message}`);
            return;
        }
        console.log(`Created ${name} (${size})`);
    });
});