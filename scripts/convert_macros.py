import re
import sys

input_file = sys.argv[1] if len(sys.argv) > 1 else "_macros.tex"

macros = []

with open(input_file, 'r') as f:
    for line in f:
        # Remove comments (ignore escaped \%)
        line = re.sub(r'(?<!\\)%.*', '', line).strip()
        if not line.startswith(r'\newcommand'):
            continue

        # Match \newcommand{\name}[n]{body} or \newcommand{\name}{body}
        match = re.match(
            r'\\newcommand\{\\([a-zA-Z]+)\}(?:\[(\d+)\])?\{(.+)\}', line)
        if match:
            name, nargs, body = match.groups()
            body = body.strip()
            body = body.replace('\\', r'\\').replace('"', r'\"')
            if nargs:
                macros.append(f'    {name}: ["\\{body}", {nargs}],')
            else:
                macros.append(f'    {name}: "\\{body}",')

# Output as HTML
print("<script>")
print("  MathJax = MathJax || {};")
print("  MathJax.tex = MathJax.tex || {};")
print("  MathJax.tex.macros = Object.assign(MathJax.tex.macros || {}, {")
print("\n".join(macros))
print("  });")
print("</script>")