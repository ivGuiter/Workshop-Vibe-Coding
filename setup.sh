#!/bin/bash

set -e  # Exit on any error

echo "Installing opencode..."
curl -fsSL https://opencode.ai/install | bash

echo "Installing Playwright test package..."
npm install -g @playwright/test

echo "Installing Playwright dependencies..."
npx playwright install-deps

echo "Installing Playwright browsers..."
npx playwright install

echo "Installing Playwright MCP..."
timeout 5 npx @playwright/mcp@latest

echo "Setup complete! Screenshots will be saved to /tmp/playwright-mcp-output/ (symlinked as ./screenshots in this repo)"