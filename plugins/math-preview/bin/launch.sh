#!/bin/bash
# Live math preview: pdflatex + Sioyek
# Polls content file for changes, compiles, Sioyek auto-reloads the PDF
# Usage: bash launch.sh

DIR="/tmp/math-preview"
CONTENT="$DIR/math_content.tex"
PDF="$DIR/math_preview.pdf"
TEMPLATE="$DIR/math_preview.tex"

# Check deps
command -v pdflatex &>/dev/null || { echo "Error: pdflatex not found. Install: brew install --cask mactex"; exit 1; }
command -v sioyek &>/dev/null || { echo "Error: sioyek not found. Install: brew install --cask sioyek"; exit 1; }

mkdir -p "$DIR"

# Generate template (fresh each run)
cat > "$TEMPLATE" << 'TEXTEMPLATE'
\documentclass[border=10pt,varwidth=30em]{standalone}

\usepackage{amsmath,amssymb,amsthm}
\usepackage{mathtools}
\usepackage{xcolor}
\usepackage{tikz}
\usepackage{pgfplots}
\pgfplotsset{compat=1.18}

% Blackboard bold
\newcommand{\R}{\mathbb{R}}
\newcommand{\N}{\mathbb{N}}
\newcommand{\Q}{\mathbb{Q}}
\newcommand{\E}{\mathbb{E}}
\newcommand{\Prb}{\mathbb{P}}

% Calligraphic
\newcommand{\Alg}{\mathcal{A}}
\newcommand{\F}{\mathcal{F}}
\newcommand{\Gs}{\mathcal{G}}

% Shortcuts
\newcommand{\ind}[1]{\mathbf{1}_{#1}}
\newcommand{\eps}{\varepsilon}

% Operators
\DeclareMathOperator{\MCT}{MCT}
\DeclareMathOperator{\Var}{Var}
\DeclareMathOperator{\Cov}{Cov}
\DeclareMathOperator{\supp}{supp}
\DeclareMathOperator{\sgn}{sgn}
\DeclareMathOperator*{\argmin}{arg\,min}
\DeclareMathOperator*{\argmax}{arg\,max}

\begin{document}
\input{/tmp/math-preview/math_content.tex}
\end{document}
TEXTEMPLATE

# Seed content if missing
[ -f "$CONTENT" ] || echo '\textit{Waiting for math content\ldots}' > "$CONTENT"

# Initial compile
cd "$DIR" && pdflatex -interaction=nonstopmode math_preview.tex > /dev/null 2>&1

# Lockfile to prevent double-launch
LOCKFILE="$DIR/.launcher.pid"
if [ -f "$LOCKFILE" ] && kill -0 "$(cat "$LOCKFILE")" 2>/dev/null; then
    echo "Math preview already running (pid $(cat "$LOCKFILE"))"
    exit 0
fi
echo $$ > "$LOCKFILE"

# Open Sioyek in a dedicated window
sioyek --new-window "$PDF" &

trap 'rm -f "$LOCKFILE"; kill 0 2>/dev/null' EXIT

echo "Math preview running"
echo "  Content: $CONTENT"
echo "  PDF:     $PDF"
echo "  Ctrl-C to stop"

# Poll and recompile on change
LAST_MTIME=""
while true; do
    MTIME=$(stat -f %m "$CONTENT" 2>/dev/null || echo "")
    if [ -n "$MTIME" ] && [ "$MTIME" != "$LAST_MTIME" ]; then
        LAST_MTIME="$MTIME"
        cd "$DIR" && pdflatex -interaction=nonstopmode math_preview.tex > /dev/null 2>&1
        grep -E "^!|Overfull|Underfull|Warning" "$DIR/math_preview.log" > "$DIR/status.txt" || echo "ok" > "$DIR/status.txt"
    fi
    sleep 0.1
done
