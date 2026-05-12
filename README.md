# tex_symbols

Personal LaTeX math macros for robotics / SLAM research.
Used in both **LaTeX papers** and **Obsidian notes**.

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
obsidian/                  # Obsidian integration (see obsidian/README.md)
├── build-preamble.ps1
├── watch-preamble.ps1
└── README.md
main.tex                   # Defines \input order (source of truth)
rules.md                   # Naming conventions
```

---

## LaTeX Paper Setup

Add as submodule at `include/tex_symbols/`:

```bash
git submodule add https://github.com/gunheeShin/tex_symbols.git include/tex_symbols
```

In your paper preamble (or copy from `main.tex`):

```latex
\input{include/tex_symbols/include/common.tex}
\input{include/tex_symbols/include/pose/pose.tex}
\input{include/tex_symbols/include/point.tex}
\input{include/tex_symbols/include/others/state.tex}
\input{include/tex_symbols/include/others/imu_inputs.tex}
\input{include/tex_symbols/include/others/others.tex}
```

---

## Obsidian Setup

See [`obsidian/README.md`](obsidian/README.md) for setup steps, plugin
configuration, and the auto-rebuild workflow.
