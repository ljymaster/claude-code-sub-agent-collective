# Phase 2 Remediation: Testing Framework

## Evidence (Present)
- Tests exist: `claude-code-collective/tests/*.test.js`
- Jest template: `claude-code-collective/templates/jest.config.js`
- Guides: `TESTING-GUIDE.md`

## Gaps
- No root `jest.config.*`
- No CI workflow
- No coverage thresholds enforced
- No root `package.json` scripts (only under `claude-code-collective/`)

## Remediation Steps
- Add root `package.json` with `test`, `test:ci`, `coverage`
- Add root `jest.config.js`; enforce coverage ≥85%
- Add CI workflow to run tests on PR/main
- Document test contracts in `ai-docs/Validation-Criteria.md`

## DoD
- `npm test` passes locally and in CI; coverage ≥ threshold
- CI blocks PRs on test/coverage failures
