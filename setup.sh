#!/bin/bash

echo "🚀 Initializing Git and Playwright Setup..."

# 1. Git Init
git init

# 2. Initialize package.json (Quietly)
npm init -y > /dev/null

# 3. Install Dependencies
npm i -D @playwright/test typescript @types/node dotenv eslint @eslint/js typescript-eslint eslint-plugin-playwright

# 4. Install Playwright Browsers
npx playwright install --with-deps

# 5. Create Folder Structure
mkdir -p e2e pages helpers/const helpers/models fixtures helpers/utils config

# 6. Create playwright.config.ts
cat <<EOF > playwright.config.ts
import { defineConfig, devices } from '@playwright/test';
import dotenv from 'dotenv';
import path from 'path';

/**
 * Read environment variables from file.
 * https://github.com/motdotla/dotenv
 */
/* Set default env to config/.env.test */
const ENV = process.env.ENV || 'test';

dotenv.config({
    path: path.resolve(__dirname, 'config', \`.env.\${ENV}\`)
});

/**
 * See https://playwright.dev/docs/test-configuration.
 */
export default defineConfig({
    testDir: './e2e',
    /* Run tests in files in parallel */
    fullyParallel: true,
    /* Fail the build on CI if you accidentally left test.only in the source code. */
    forbidOnly: !!process.env.CI,
    /* Retry on CI only */
    retries: process.env.CI ? 2 : 0,
    /* Opt out of parallel tests on CI. */
    workers: process.env.CI ? 1 : undefined,
    /* Reporter to use. See https://playwright.dev/docs/test-reporters */
    reporter: 'html',
    /* Shared settings for all the projects below. See https://playwright.dev/docs/api/class-testoptions. */
    use: {
        /* Base URL to use in actions like \`await page.goto('')\`. */
        // baseURL: 'http://localhost:3000',
        // baseURL: process.env.BASE_URL,

        /* Collect trace when retrying the failed test. See https://playwright.dev/docs/trace-viewer */
        trace: 'on-first-retry',
    },

    /* Configure projects for major browsers */
    projects: [
        {
            name: 'chromium',
            use: { ...devices['Desktop Chrome'] },
        },

        {
            name: 'firefox',
            use: { ...devices['Desktop Firefox'] },
        },

        {
            name: 'webkit',
            use: { ...devices['Desktop Safari'] },
        },

        /* Test against mobile viewports. */
        // {
        //     name: 'Mobile Chrome',
        //     use: { ...devices['Pixel 5'] },
        // },
        // {
        //     name: 'Mobile Safari',
        //     use: { ...devices['iPhone 12'] },
        // },

        /* Test against branded browsers. */
        // {
        //     name: 'Microsoft Edge',
        //     use: { ...devices['Desktop Edge'], channel: 'msedge' },
        // },
        // {
        //     name: 'Google Chrome',
        //     use: { ...devices['Desktop Chrome'], channel: 'chrome' },
        // },
    ],

    /* Run your local dev server before starting the tests */
    // webServer: {
    //     command: 'npm run start',
    //     url: 'http://localhost:3000',
    //     reuseExistingServer: !process.env.CI,
    // },
});
EOF

# 7. Create tsconfig.json
cat <<EOF > tsconfig.json
{
  "compilerOptions": {
    "esModuleInterop": true,
    "noImplicitAny": true,
    "noImplicitThis": true,
    "alwaysStrict": true,
    "strictNullChecks": false,
    "paths": {
      "@const/*": ["./helpers/const/*"],
      "@fixtures/*": ["./fixtures/*"],
      "@models/*": ["./helpers/models/*"],
      "@pages/*": ["./pages/*"],
      "@utils/*": ["./helpers/utils/*"]
    }
  }
}
EOF

# 8. Create eslint.config.mjs
cat <<EOF > eslint.config.mjs
import eslint from '@eslint/js';
import { defineConfig } from 'eslint/config';
import tseslint from 'typescript-eslint';
import playwright from 'eslint-plugin-playwright';

export default defineConfig(
    eslint.configs.recommended,
    tseslint.configs.recommended,
    {
        files: ["**/*.{ts,tsx}"],
        extends: [playwright.configs['flat/recommended']],
        languageOptions: {
            parserOptions: {
                projectService: true,
            },
        },
        rules: {
            "@typescript-eslint/no-floating-promises": "error",
            "@typescript-eslint/await-thenable": "error",
            "@typescript-eslint/no-unused-vars": [
                "error",
                {
                    "args": "all",
                    "argsIgnorePattern": "^_",
                    "caughtErrors": "all",
                    "caughtErrorsIgnorePattern": "^_",
                    "destructuredArrayIgnorePattern": "^_",
                    "varsIgnorePattern": "^_",
                    "ignoreRestSiblings": true
                }
            ],
        }
    },
);
EOF

# 9. Create Environment Config
echo "BASE_URL=https://yourtestapp.com" > config/.env.test

# 10. Create .gitignore
cat <<EOF > .gitignore
# Playwright
node_modules/
/test-results/
/playwright-report/
/blob-report/
/playwright/.cache/
/playwright/.auth/

# Environment Variables
.env*
!.env.example
EOF

# 11. Update Package Scripts
npm pkg set scripts.pretest="tsc --noEmit && eslint ." scripts.test="playwright test"

echo "✅ Git initialized and Setup complete!"