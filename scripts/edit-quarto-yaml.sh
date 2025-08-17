#!/bin/bash
set -e

cd "$(git rev-parse --show-toplevel)"
echo "📁 Working from project root: $(pwd)"

OUTDIR="__autogen"
SRC="_quarto.yml"
OUT="$OUTDIR/quarto_result.yml"

mkdir -p "$OUTDIR"
rm -f "$OUTDIR"/*.yml

# ▶️ Generate new sidebar
chmod +x scripts/grab_contents_v2.sh
scripts/grab_contents_v2.sh > "$OUTDIR/sidebar.yml"
echo "✅ Sidebar written to $OUTDIR/sidebar.yml"

# ▶️ Extract head: everything before sidebar:
awk '
  BEGIN { inside_sidebar = 0 }
  /^[ ]*sidebar:/ { inside_sidebar = 1 }
  !inside_sidebar { print }
' "$SRC" > "$OUTDIR/head.yml"

# ▶️ Extract tail: everything after sidebar block ends
awk '
  BEGIN { copying = 0; in_sidebar = 0 }
  /^[ ]*sidebar:/ { in_sidebar = 1; next }
  in_sidebar && (/^[ ]{2}[^ ]/ || /^[^ ]/) { copying = 1 }
  copying { print }
' "$SRC" > "$OUTDIR/tail.yml"

# ▶️ Step 3.5: Indent sidebar.yml by 2 spaces
sed 's/^/  /' "$OUTDIR/sidebar.yml" > "$OUTDIR/sidebar.indented.yml"

# ▶️ Combine into final result
cat "$OUTDIR/head.yml" "$OUTDIR/sidebar.indented.yml" "$OUTDIR/tail.yml" > "$OUT"
echo "✅ Clean result written to: $OUT"

# ▶️ Step 4: Compare and update if changed
# Cannot return non-zero otherwise Github would confuse
if cmp -s "$OUT" "$SRC"; then
  echo "🟢 No sidebar changes detected. $SRC is up to date."
else
  echo "🟡 Sidebar updated. Overwriting $SRC..."
  cp "$OUT" "$SRC"
  touch __autogen/sidebar-changed.flag
fi