#!/bin/bash

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

README="README.md"
INDEX_FILE=".theme_index"

if [ ! -f $INDEX_FILE ]; then
  echo 0 > $INDEX_FILE
fi

INDEX=$(cat $INDEX_FILE)
TOTAL=${#THEMES[@]}
NEW_THEME=${THEMES[$INDEX]}

echo "Switching to theme: $NEW_THEME"

# Safe replace (only profile card line)
sed -i "s|card/nayandas69?theme=[^\"]*|card/nayandas69?theme=$NEW_THEME|g" $README

NEXT_INDEX=$(( (INDEX + 1) % TOTAL ))
echo $NEXT_INDEX > $INDEX_FILE

git config user.name "nayandas69"
git config user.email "174907517+nayandas69@users.noreply.github.com"

git pull --rebase origin main || true
git add .
git commit -m "🎨 Auto rotate theme: $NEW_THEME" || echo "No changes to commit"
git push origin main