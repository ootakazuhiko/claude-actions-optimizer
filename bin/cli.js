#!/usr/bin/env node
const { execSync } = require('child_process');
const path = require('path');

const command = process.argv[2];
const projectType = process.argv[3] || 'auto';

console.log('🤖 Claude Actions Optimizer CLI\n');

switch (command) {
  case 'init':
    console.log('🚀 Initializing Claude Actions Optimizer...');
    try {
      const scriptPath = path.join(__dirname, '..', 'install.sh');
      execSync(`bash ${scriptPath}`, { stdio: 'inherit' });
    } catch (error) {
      console.error('❌ Installation failed:', error.message);
      process.exit(1);
    }
    break;
    
  case 'quick':
    console.log('⚡ Quick deployment...');
    try {
      const scriptPath = path.join(__dirname, '..', 'quick-deploy.sh');
      execSync(`bash ${scriptPath} . ${projectType}`, { stdio: 'inherit' });
    } catch (error) {
      console.error('❌ Quick deployment failed:', error.message);
      process.exit(1);
    }
    break;
    
  default:
    console.log(`
Claude Actions Optimizer - Reduce GitHub Actions costs by 80-95%

Usage:
  npx claude-actions-optimizer init         # Full installation
  npx claude-actions-optimizer quick        # Quick deployment (auto-detect)
  npx claude-actions-optimizer quick nodejs # Node.js project
  npx claude-actions-optimizer quick python # Python project

Examples:
  cd my-project
  npx claude-actions-optimizer init
  
For more information:
  https://github.com/ootakazuhiko/claude-actions-optimizer
    `);
}