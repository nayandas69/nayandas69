#!/usr/bin/env bash
set -Eeuo pipefail

# Profile theme rotation — safe, limited file changes.
readonly README="README.md"
readonly INDEX_FILE=".theme_index"

THEMES=(
  "default" "dark" "dracula" "monokai" "nord" "github_dark"
  "slate" "midnight" "highcontrast" "pearl" "ice" "sand"
  "pastel_peach" "pastel_mint" "pastel_lavender" "pastel_lemon"
  "pastel_rose" "mui_blue" "mui_indigo" "mui_teal"
  "mui_deep_purple" "mui_orange" "mui_red"
  "vscode_dark_plus" "vscode_light" "vscode_monokai_pro"
  "vscode_night_owl" "vscode_palenight"
  "twitter" "discord" "spotify" "github_light"
  "youtube" "instagram" "radical" "cyberpunk"
  "synthwave" "oceanic" "mint" "royal"
  "gruvbox" "merko" "forest" "rose"
  "sunset" "lavender" "ember" "tokyonight"
  "onedark" "cobalt"
  "amoled_blue" "amoled_green" "amoled_purple"
  "grayscale_light" "grayscale_mid" "grayscale_dark"
)

readonly TOTAL=${#THEMES[@]}

# Do not run outside the checked-out repository.
git rev-parse --is-inside-work-tree >/dev/null
[[ -f "$README" ]] || {
  echo "::error::README.md not found."
  exit 1
}

# Refuse to operate on an unexpected branch.
BRANCH="$(git branch --show-current)"
if [[ "$BRANCH" != "main" ]]; then
  echo "::error::Expected branch main, got: $BRANCH"
  exit 1
fi

# Read and validate the saved index.
INDEX=0
if [[ -f "$INDEX_FILE" ]]; then
  IFS= read -r INDEX < "$INDEX_FILE" || INDEX=0
fi

if [[ ! "$INDEX" =~ ^[0-9]+$ ]] || (( INDEX >= TOTAL )); then
  echo "Invalid theme index; resetting to 0."
  INDEX=0
fi

NEW_THEME="${THEMES[$INDEX]}"
NEXT_INDEX=$(( (INDEX + 1) % TOTAL ))

echo "Available themes: $TOTAL"
echo "Current theme: $NEW_THEME"
echo "Next index: $NEXT_INDEX"

# Require the expected URL and update only the theme query parameter.
# The replacement must occur at least once.
if ! grep -Fq 'card/nayandas69?theme=' "$README"; then
  echo "::error::Expected profile card URL not found in README.md."
  exit 1
fi

sed -i \
  "s|card/nayandas69?theme=[^\"]*|card/nayandas69?theme=${NEW_THEME}|g" \
  "$README"

# Save the next index.
printf '%s\n' "$NEXT_INDEX" > "$INDEX_FILE"

# Stage only the two intended files.
git add -- "$README" "$INDEX_FILE"

# Avoid empty commits.
if git diff --cached --quiet; then
  echo "No changes to commit."
  exit 0
fi

git config user.name "github-actions[bot]"
git config user.email "41898282+github-actions[bot]@users.noreply.github.com"

git commit -m "chore: rotate profile theme to ${NEW_THEME}"

# Do not force-push or hide push failures.
git push origin HEAD:main

echo "Theme rotation completed successfully."
