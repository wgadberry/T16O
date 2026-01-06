// This script sets up HTTPS for the application using the ASP.NET Core HTTPS certificate
const fs = require('fs');
const spawn = require('child_process').spawn;
const spawnSync = require('child_process').spawnSync;
const path = require('path');

const baseFolder =
  process.env.APPDATA !== undefined && process.env.APPDATA !== ''
    ? `${process.env.APPDATA}/ASP.NET/https`
    : `${process.env.HOME}/.aspnet/https`;

const certificateArg = process.argv.map(arg => arg.match(/--name=(?<value>.+)/i)).filter(Boolean)[0];
const certificateName = certificateArg ? certificateArg.groups.value : process.env.npm_package_name;

if (!certificateName) {
  console.error('Invalid certificate name. Run this script in the context of an npm/yarn script or pass --name=<<app>> explicitly.')
  process.exit(-1);
}

const certFilePath = path.join(baseFolder, `${certificateName}.pem`);
const keyFilePath = path.join(baseFolder, `${certificateName}.key`);

if (!fs.existsSync(baseFolder)) {
    fs.mkdirSync(baseFolder, { recursive: true });
}

// Check if certificate needs to be regenerated (--force flag or missing files)
const forceRegenerate = process.argv.includes('--force');

if (forceRegenerate || !fs.existsSync(certFilePath) || !fs.existsSync(keyFilePath)) {
  console.log('Setting up HTTPS development certificate...');

  // Clean existing certificates
  console.log('Cleaning existing dev certificates...');
  spawnSync('dotnet', ['dev-certs', 'https', '--clean'], { stdio: 'inherit' });

  // Remove old exported files if they exist
  if (fs.existsSync(certFilePath)) fs.unlinkSync(certFilePath);
  if (fs.existsSync(keyFilePath)) fs.unlinkSync(keyFilePath);

  // Generate and trust new certificate
  console.log('Generating and trusting new certificate...');
  const trustResult = spawnSync('dotnet', ['dev-certs', 'https', '--trust'], { stdio: 'inherit' });

  if (trustResult.status !== 0) {
    console.error('Failed to generate/trust certificate');
    process.exit(1);
  }

  // Export the certificate
  console.log('Exporting certificate...');
  spawn('dotnet', [
    'dev-certs',
    'https',
    '--export-path',
    certFilePath,
    '--format',
    'Pem',
    '--no-password',
  ], { stdio: 'inherit' })
  .on('exit', (code) => {
    if (code === 0) {
      console.log('HTTPS certificate setup complete!');
    }
    process.exit(code);
  });
} else {
  console.log('HTTPS certificate already exists. Use --force to regenerate.');
}