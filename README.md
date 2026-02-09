# Playwright E2E Automation Setup

A modular, opinionated Playwright boilerplate generator using TypeScript, Page Object Model (POM), and strict ESLint configuration. This repository hosts the setup script to instantly scaffold a new framework.

## ⚡ Quick Start

Run this in Bash to set up a full Playwright framework in the current directory:

```bash
curl -sSL https://raw.githubusercontent.com/asteria-dev/playwright-setup/main/setup.sh | bash
```

### What this does:
1.  Initializes a **Git** repository and **Node.js** project.
2.  Installs **Playwright**, **TypeScript**, and **ESLint** (Flat Config).
3.  Creates the **folder structure** (POM, helpers, fixtures).
4.  Configures **path aliases** (`@pages`, `@utils`, etc.).
5.  Sets up **Dotenv** to load from `config/.env.*`.

---

## 📂 Architecture

The framework enforces a strict separation of concerns:

```text
├── 📁 config/           # Environment variables (.env.test, .env.staging)
├── 📁 e2e/              # Test files (*.spec.ts)
├── 📁 fixtures/         # Playwright test fixtures
├── 📁 helpers/
│   ├── 📁 const/        # Static constants + derived types
│   ├── 📁 models/       # TypeScript interfaces/types
│   └── 📁 utils/        # Shared helper functions
├── 📁 pages/            # Page Objects
├── .gitignore           # Pre-configured for Playwright & secrets
├── eslint.config.mjs    # Flat config with strict async rules
├── playwright.config.ts # Main configuration
└── tsconfig.json        # Path alias mappings
```

---

## 🛠️ Key Features

### 1. Path Aliases
Avoid "dot-hell" (`../../`) by using pre-configured aliases in `tsconfig.json`:

| Alias | Maps to | Use Case |
| :--- | :--- | :--- |
| **`@pages/*`** | `./pages/*` | Importing Page Objects |
| **`@utils/*`** | `./helpers/utils/*` | Shared logic |
| **`@const/*`** | `./helpers/const/*` | Selectors, URLs, Text |
| **`@models/*`** | `./helpers/models/*` | Types & Interfaces |
| **`@fixtures/*`** | `./fixtures/*` | Custom fixtures |

### 2. Environment Management
The `playwright.config.ts` is set up to load environment variables dynamically.
* **Default:** Loads `config/.env.test`
* **Custom:** Run with `ENV=staging` to load `config/.env.staging
```bash
# Run tests using config/.env.staging
ENV=staging npm test
```

### 3. Strict Linting
Includes `eslint-plugin-playwright` and strictly enforces:
* **Floating Promises:** You must `await` all async Playwright actions.
* **Unused Variables:** Throws errors for cleaner code (prefix with `_` to ignore).

---

## 🤖 Scripts

| Command | Description |
| :--- | :--- |
| `npm test` | Runs Playwright tests (headless by default). |
| `npm run pretest` | Runs TypeScript type-checking (`tsc`) and Linting. |
| `npx playwright test --ui` | Opens the interactive UI mode. |

---

## 📝 Example Usage

**`e2e/example.spec.ts`**
```typescript
import { test, expect } from '@playwright/test';
import { LoginPage } from '@pages/LoginPage';
import { USER_DATA } from '@const/users';

test('should login successfully', async ({ page }) => {
    const loginPage = new LoginPage(page);
    await loginPage.navigate();
    await loginPage.login(USER_DATA.admin);

    await expect(page).toHaveURL(/dashboard/);
});

```