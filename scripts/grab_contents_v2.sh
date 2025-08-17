#!/bin/bash

echo "sidebar:"
echo "  style: \"docked\""
echo "  background: dark"
echo "  collapse-level: 1"
echo "  contents:"

# Loop through each chapter folder
for chapter in $(find contents -mindepth 1 -maxdepth 1 -type d | sort); do
  # Get the basename like "chapter-02"
  folder_name=$(basename "$chapter")
  # Obtain the index path
  index_path="$chapter/index.qmd"

  # Extract number from folder name using parameter expansion or regex
  chapter_num=$(echo "$folder_name" | sed -E 's/[^0-9]*([0-9]+).*/\1/')
  chapter_num=$(printf "%02d" "$((10#$chapter_num))")

  # Default to Folder Name
  chapter_name="$folder_name"

  # Extract the Title Line if Any
  if [[ -f "$index_path" ]]; then
    title_line=$(grep -m 1 '^title:' "$index_path")
    if [[ -n "$title_line" ]]; then
      chapter_title=$(echo "$title_line" | sed -E 's/^title:[[:space:]]*["'\''"]?([^"'\''"]+)["'\''"]?/\1/')
      chapter_name=$(printf "CH%02d : %s" "$((10#$chapter_num))" "$chapter_title")
    fi
  fi

  # Find all .qmd files (excluding index.qmd)
  other_qmds=$(find "$chapter" -maxdepth 1 -name '*.qmd' ! -name 'index.qmd' | sort)

  if [[ -f "$index_path" && -z "$other_qmds" ]]; then
    # Only index.qmd exists → use text + href
    echo "    - text: \"$chapter_name\""
    echo "      href: $index_path"
  else
    # index.qmd + others → use section + href + contents
    echo "    - section: \"$chapter_name\""
    if [[ -f "$index_path" ]]; then
      echo "      href: $index_path"
    fi
    if [[ -n "$other_qmds" ]]; then
      echo "      contents:"
      while IFS= read -r file; do
        echo "        - $file"
      done <<< "$other_qmds"
    fi
  fi
done