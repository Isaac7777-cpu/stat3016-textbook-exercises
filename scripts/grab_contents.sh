#!/bin/bash
echo "sidebar:"
echo "  style: \"docked\""
echo "  background: dark"
echo "  collapse-level: 1"
echo "  contents:"

for chapter in $(find contents -mindepth 1 -maxdepth 1 -type d | sort); do
  chapter_name=$(basename "$chapter")
  chapter_title=$(echo "$chapter_name" | sed 's/-/ /g' | sed 's/\b\(.\)/\u\1/g')
  echo "    - section: \"$chapter_title\""
  echo "      contents:"
  find "$chapter" -name '*.qmd' | sort | while read file; do
    echo "        - $file"
  done
done
