#!/usr/bin/env bash
# verify-install.sh — Post-reinstall verification for everything-claude-code
set -euo pipefail
PASS=0; FAIL=0; WARN=0

check() {
  local desc="$1"; shift
  if "$@" >/dev/null 2>&1; then
    echo "  PASS $desc"; PASS=$((PASS+1))
  else
    echo "  FAIL $desc"; FAIL=$((FAIL+1))
  fi
}

warn_check() {
  local desc="$1"; shift
  if "$@" >/dev/null 2>&1; then
    echo "  PASS $desc"; PASS=$((PASS+1))
  else
    echo "  WARN $desc (non-critical)"; WARN=$((WARN+1))
  fi
}

echo "Post-Install Verification"
echo "========================="
echo ""
echo "Dependencies"
check "node installed" node --version
check "npm installed" npm --version
check "node_modules present" test -d node_modules
check "npm audit clean (high)" npm audit --audit-level=high

echo ""
echo "Lint and Test"
check "eslint passes" npx eslint scripts/**/*.js tests/**/*.js
check "markdownlint passes" npx markdownlint "agents/**/*.md" "skills/**/*.md" --config .markdownlint.json
check "test suite passes" node tests/run-all.js

echo ""
echo "Manifest Sync"
AGENT_DISK=$(find agents -maxdepth 1 -name '*.md' ! -name 'README*' 2>/dev/null | wc -l | tr -d ' ')
AGENT_JSON=$(node -p "require('./.claude-plugin/plugin.json').agents.length" 2>/dev/null || echo 0)
check "VERSION matches package.json" diff <(node -p "require('./package.json').version") VERSION
if [ "$AGENT_DISK" = "$AGENT_JSON" ]; then
  echo "  PASS Agent count synced ($AGENT_DISK on disk, $AGENT_JSON in manifest)"
  PASS=$((PASS+1))
else
  echo "  FAIL Agent count mismatch ($AGENT_DISK on disk, $AGENT_JSON in manifest)"
  FAIL=$((FAIL+1))
fi

echo ""
echo "Claude Code State"
warn_check "~/.claude/settings.json exists" test -f ~/.claude/settings.json
warn_check "~/.claude/skills/ exists" test -d ~/.claude/skills/
warn_check "~/.claude/scheduled-tasks/ exists" test -d ~/.claude/scheduled-tasks/
warn_check "~/.claude/hooks/ exists" test -d ~/.claude/hooks/

echo ""
echo "Claude Desktop Config"
DESKTOP_CFG="${HOME}/Library/Application Support/Claude/claude_desktop_config.json"
warn_check "Desktop config exists" test -f "$DESKTOP_CFG"
if [ -f "$DESKTOP_CFG" ]; then
  MCP_COUNT=$(python3 -c "import json; print(len(json.load(open('$DESKTOP_CFG')).get('mcpServers',{})))" 2>/dev/null || echo 0)
  if [ "$MCP_COUNT" -ge 3 ]; then
    echo "  PASS MCP servers configured ($MCP_COUNT)"
    PASS=$((PASS+1))
  else
    echo "  WARN Only $MCP_COUNT MCP servers (expected 3+)"
    WARN=$((WARN+1))
  fi
fi

echo ""
echo "Claude Extensions"
EXT_DIR="${HOME}/Library/Application Support/Claude/Claude Extensions"
if [ -d "$EXT_DIR" ]; then
  EXT_COUNT=$(find "$EXT_DIR" -maxdepth 1 -type d | wc -l | tr -d ' ')
  EXT_COUNT=$((EXT_COUNT - 1))  # subtract the dir itself
  if [ "$EXT_COUNT" -ge 3 ]; then
    echo "  PASS Claude Extensions installed ($EXT_COUNT)"
    PASS=$((PASS+1))
  else
    echo "  WARN Only $EXT_COUNT extensions found (expected 3+)"
    WARN=$((WARN+1))
  fi
else
  echo "  WARN Claude Extensions directory not found (reinstall from marketplace)"
  WARN=$((WARN+1))
fi

echo ""
echo "Memory Systems"
warn_check "~/.basic-memory/ exists" test -d ~/.basic-memory/
warn_check "~/.openclaw/ exists" test -d ~/.openclaw/

echo ""
echo "OpenClaw"
warn_check "~/.openclaw/openclaw.json exists" test -f ~/.openclaw/openclaw.json
warn_check "~/.openclaw/.env exists" test -f ~/.openclaw/.env

echo ""
echo "========================="
echo "Results: $PASS passed, $FAIL failed, $WARN warnings"
if [ "$FAIL" -gt 0 ]; then
  echo "FAILED — fix $FAIL issues above"
  exit 1
else
  echo "PASSED"
fi
