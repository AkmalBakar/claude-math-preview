---
description: Live LaTeX math preview - renders formulas, derivations, and tikz diagrams in a Sioyek window
---

# Math Preview

Live LaTeX rendering via pdflatex + Sioyek. Write math to a file and the preview updates automatically (~400ms).

## Prerequisites

The user needs these installed on macOS:
- **texlive**: `brew install --cask mactex`
- **sioyek**: `brew install --cask sioyek`

## Setup

The launcher must be running on the host. Check `/tmp/math-preview/.launcher.pid` — if missing or stale, tell the user to run:
```
bash ${CLAUDE_PLUGIN_ROOT}/bin/launch.sh
```

## How to show math

Every time you produce a non-trivial formula, derivation, or proof step:

**Write** the LaTeX body to `/tmp/math-preview/math_content.tex` using Bash with a heredoc (NOT the Write tool — avoids reading the old file into context):

```bash
cat > /tmp/math-preview/math_content.tex << 'EOF'
\[ your LaTeX here \]
EOF
```

That's it. The launcher polls for changes, compiles, and Sioyek auto-reloads the PDF.

## Debugging

If the preview doesn't update, check `/tmp/math-preview/status.txt`:
- `ok` — compile succeeded
- Error lines (prefixed with `!`) or warnings (Overfull/Underfull) — fix the LaTeX and write again

## Rules

- **Overwrite** the file each time — each write is a complete snapshot, not an append.
- **No preamble.** No `\documentclass`, `\usepackage`, or `\begin{document}`. The template handles that.
- Use `\[ ... \]` or `align*` for display math. Use `\text{}` or `\textbf{}` for labels.
- Tikz and pgfplots are available — use `\begin{tikzpicture}` directly.
- You can include multiple equations, text, diagrams, and structure — it's a full LaTeX body.

## Available macros

Pre-defined in the template:

| Macro | Output |
|-------|--------|
| `\R \N \Q \E \Prb` | Blackboard bold R, N, Q, E, P |
| `\F \Gs \Alg` | Calligraphic F, G, A |
| `\ind{A}` | Indicator 1_A |
| `\eps` | Varepsilon |
| `\Var \Cov \supp \sgn` | Operators |
| `\argmin \argmax` | arg min, arg max |
| `\MCT` | MCT operator |
