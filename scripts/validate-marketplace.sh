#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

echo "== Validating marketplace.json =="
jq -e '.plugins | length == 3' .claude-plugin/marketplace.json > /dev/null
echo "OK: 3 plugins declared"

echo "== Validating each plugin =="
for name in $(jq -r '.plugins[].name' .claude-plugin/marketplace.json); do
  source_path=$(jq -r --arg n "$name" '.plugins[] | select(.name == $n) | .source' .claude-plugin/marketplace.json)
  dir="${source_path#./}"

  test -d "$dir" || { echo "FAIL: $dir does not exist for plugin $name"; exit 1; }

  plugin_json="$dir/.claude-plugin/plugin.json"
  test -f "$plugin_json" || { echo "FAIL: missing $plugin_json"; exit 1; }
  jq -e --arg n "$name" '.name == $n' "$plugin_json" > /dev/null \
    || { echo "FAIL: $plugin_json name field does not match '$name'"; exit 1; }

  skills_dir="$dir/skills"
  skill_count=$(find "$skills_dir" -name "SKILL.md" | wc -l | tr -d ' ')
  [ "$skill_count" -ge 1 ] || { echo "FAIL: no SKILL.md found under $skills_dir"; exit 1; }

  find "$skills_dir" -name "SKILL.md" | while read -r skill_file; do
    head -1 "$skill_file" | grep -q '^---$' \
      || { echo "FAIL: $skill_file missing frontmatter opening ---"; exit 1; }
    grep -q '^name:' "$skill_file" \
      || { echo "FAIL: $skill_file missing 'name:' frontmatter field"; exit 1; }
    grep -q '^description:' "$skill_file" \
      || { echo "FAIL: $skill_file missing 'description:' frontmatter field"; exit 1; }
  done

  echo "OK: $name ($skill_count SKILL.md)"
done

echo "== All checks passed =="
