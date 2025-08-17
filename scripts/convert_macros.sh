#!/bin/bash

INPUT="_macros.tex"
OUTPUT="scripts/mathjax-macros.html"

echo "🔧 Generating $OUTPUT from $INPUT..."

# Prepare header
cat <<EOF > "$OUTPUT"
<script>
  MathJax = MathJax || {};
  MathJax.tex = MathJax.tex || {};
  MathJax.tex.macros = Object.assign(MathJax.tex.macros || {}, {
EOF

# Extract macros
awk '
function trim(s) {
  sub(/^[ \t\r\n]+/, "", s)
  sub(/[ \t\r\n]+$/, "", s)
  return s
}
function escape(s) {
  gsub(/\\/, "\\\\", s)
  return s
}
function parse_macro(line) {
  # remove comment
  sub(/%.*/, "", line)
  line = trim(line)

  if (index(line, "\\newcommand{\\") != 1) return

  # case: no argument
  if (line ~ /^\\newcommand{\\[a-zA-Z]+}{/) {
    name_start = index(line, "{\\") + 2
    name_end = index(substr(line, name_start), "}") - 1
    name = substr(line, name_start, name_end)

    body_start = index(line, "}{" ) + 2
    body = substr(line, body_start)
    sub(/}$/, "", body)
    body = escape(body)
    printf("    %s: \"%s\",\n", name, body)
  }

  # case: with argument
  else if (line ~ /^\\newcommand{\\[a-zA-Z]+}\[[0-9]+\]{/) {
    name_start = index(line, "{\\") + 2
    name_end = index(substr(line, name_start), "}") - 1
    name = substr(line, name_start, name_end)

    arg_start = index(line, "}[") + 2
    arg_end = index(substr(line, arg_start), "]") - 1
    nargs = substr(line, arg_start, arg_end)

    body_start = index(line, "]{" ) + 2
    body = substr(line, body_start)
    sub(/}$/, "", body)
    body = escape(body)
    printf("    %s: [\"%s\", %s],\n", name, body, nargs)
  }
}
{ parse_macro($0) }
' "$INPUT" >> "$OUTPUT"

# Close script block
cat <<EOF >> "$OUTPUT"
  });
</script>
EOF

echo "✅ Done. Output written to $OUTPUT"