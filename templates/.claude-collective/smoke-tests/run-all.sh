#!/bin/bash
# Run all smoke tests for Claude Code Collective
# These tests validate the installation and core functionality

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

TOTAL_TESTS=0
TOTAL_PASSED=0
TOTAL_FAILED=0

echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  Claude Code Collective Smoke Tests   ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
echo ""

# Find all smoke test scripts
SMOKE_TESTS=("$SCRIPT_DIR"/*.test.sh)

if [[ ${#SMOKE_TESTS[@]} -eq 0 ]] || [[ ! -f "${SMOKE_TESTS[0]}" ]]; then
    echo -e "${YELLOW}⚠️  No smoke tests found${NC}"
    exit 0
fi

# Run each test
for test_script in "${SMOKE_TESTS[@]}"; do
    if [[ -f "$test_script" ]] && [[ -x "$test_script" ]]; then
        test_name=$(basename "$test_script" .test.sh)
        echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${BLUE}Running: $test_name${NC}"
        echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo ""

        if "$test_script"; then
            echo -e "${GREEN}✅ $test_name PASSED${NC}"
            TOTAL_PASSED=$((TOTAL_PASSED+1))
        else
            echo -e "${RED}❌ $test_name FAILED${NC}"
            TOTAL_FAILED=$((TOTAL_FAILED+1))
        fi

        TOTAL_TESTS=$((TOTAL_TESTS+1))
        echo ""
    fi
done

# Summary
echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║          Test Summary                  ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
echo ""
echo -e "Total Tests: $TOTAL_TESTS"
echo -e "${GREEN}Passed: $TOTAL_PASSED${NC}"

if [[ $TOTAL_FAILED -gt 0 ]]; then
    echo -e "${RED}Failed: $TOTAL_FAILED${NC}"
    echo ""
    echo -e "${RED}❌ SMOKE TESTS FAILED${NC}"
    exit 1
else
    echo -e "${YELLOW}Failed: $TOTAL_FAILED${NC}"
    echo ""
    echo -e "${GREEN}✅ ALL SMOKE TESTS PASSED${NC}"
    exit 0
fi
