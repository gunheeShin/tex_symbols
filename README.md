# tex_symbols

Personal LaTeX math macros for robotics / SLAM research.
Used in both **Obsidian notes** (via MathJax) and **LaTeX papers**.

---

## Structure

```
include/
├── common.tex             # Frames: IMU, Lidar, World, Body
├── point.tex              # Point, Bearing, Range
├── pose/
│   └── pose.tex           # Pose, Rotation, Translation
└── others/
    ├── state.tex
    ├── imu_inputs.tex
    └── others.tex
main.tex                   # Defines \input order (source of truth)
build-preamble.ps1         # Concatenation build script
watch-preamble.ps1         # File watcher (auto-rebuild)
rules.md                   # Naming conventions
```

---

## Obsidian Setup

### 1. Clone as submodule into vault

```bash
git submodule add https://github.com/gunheeShin/tex_symbols.git tex
```

### 2. Install MathJax Preamble Manager

- Install **BRAT** from Obsidian community plugins
- In BRAT: Add Beta plugin → `RyotaUshio/obsidian-mathjax-preamble`
- Enable the plugin

Settings (`MathJax Preamble Manager`):
1. **Register preambles** → Add → `preamble.sty`
2. **Folder preambles** → Add → Folder: `/`, Preamble: `preamble.sty`

### 3. Initial build

```powershell
pwsh -ExecutionPolicy Bypass -File tex/build-preamble.ps1
```

→ `preamble.sty` generated at vault root. Obsidian loads it automatically.

### 4. Terminal alias (add to PowerShell `$PROFILE`)

```powershell
function watch-tex {
    pwsh -ExecutionPolicy Bypass -File "C:\path\to\vault\tex\watch-preamble.ps1"
}
```

Replace `C:\path\to\vault` with your actual vault path.

Then run `watch-tex` from any terminal to start the watcher.

---

## How it works

```
Edit tex/include/*.tex
        |
        v
watch-preamble.ps1 (FileSystemWatcher)
        |  detects change
        v
build-preamble.ps1
        |  parses main.tex for \input order
        |  concatenates include/**/*.tex
        v
preamble.sty  (vault root, UTF-8 no BOM)
        |
        v
MathJax Preamble Manager (Obsidian plugin)
        |  hot-reloads on file change
        v
Macros available in all notes instantly
```

`main.tex` defines the `\input` order — adding or removing a file there
automatically changes the build output without touching the build script.

---

## LaTeX Paper Setup

Add as submodule at `include/tex_symbols/`:

```bash
git submodule add https://github.com/gunheeShin/tex_symbols.git include/tex_symbols
```

In your paper preamble:

```latex
\input{include/tex_symbols/include/common.tex}
\input{include/tex_symbols/include/pose/pose.tex}
\input{include/tex_symbols/include/point.tex}
\input{include/tex_symbols/include/others/state.tex}
\input{include/tex_symbols/include/others/imu_inputs.tex}
\input{include/tex_symbols/include/others/others.tex}
```

Or simply copy `main.tex` contents into your paper preamble.
