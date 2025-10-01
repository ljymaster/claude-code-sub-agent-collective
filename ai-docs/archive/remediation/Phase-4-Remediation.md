# Phase 4 Remediation: NPX Package

## Evidence (Present)
- `claude-code-collective/package.json` with `bin` entries
- Installer script: `claude-code-collective/bin/install-collective.js`

## Gaps
- No published package/versioning plan here
- No install/test instructions validated end-to-end
- No CI publish workflow

## Remediation Steps
- Define package name/version; add `npm publish` workflow
- Add install docs and an integration test that executes installed CLI
- Verify cross-platform (WSL2/Linux) install path and permissions

## DoD
- `npx <package>` installs and runs core commands successfully in CI
