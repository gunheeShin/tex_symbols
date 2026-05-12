# Obsidian Integration

Scripts and instructions for using `tex_symbols` macros in Obsidian via the
**MathJax Preamble Manager** plugin.

## Contents

- `build-preamble.ps1` — concatenates `../include/**/*.tex` into `preamble.sty` at vault root
- `watch-preamble.ps1` — `FileSystemWatcher` that auto-rebuilds on `.tex` change

---

## Setup

### 1. Clone `tex_symbols` as submodule into vault

```bash
git submodule add https://github.com/gunheeShin/tex_symbols.git tex
```

### 2. Initial build

```powershell
pwsh -ExecutionPolicy Bypass -File tex/obsidian/build-preamble.ps1
```

→ Generates `preamble.sty` at vault root.

### 3. Install MathJax Preamble Manager (via BRAT)

1. `Settings → Community plugins → Browse` → **BRAT** 검색 후 설치 및 활성화
2. BRAT 설정 → **Add Beta plugin** → `RyotaUshio/obsidian-mathjax-preamble` 입력
3. Community plugins 목록에서 **MathJax Preamble Manager** 활성화

### 4. Plugin 설정

`Settings → MathJax Preamble Manager` 진입.

**섹션 1 — Register preambles** (파일 등록):
1. **Add** 클릭 → `Preamble 1` 행 생성
2. **"Path to preamble"** 입력칸 → `preamble.sty` 입력 (자동완성에서 선택 가능)

**섹션 2 — Folder preambles** (적용 범위 지정):
1. **Add** 클릭 → `Folder preamble 1` 행 생성 (입력칸 2개)
2. 왼쪽 **"Folder path"** → `/` 입력 (vault 전체에 적용)
3. 오른쪽 **"Preamble path"** → `preamble.sty` 선택

설정창 닫으면 즉시 적용됨 (앱 재시작 불필요).

### 5. Terminal alias (PowerShell `$PROFILE`에 추가)

```powershell
# tex_symbols watcher
function watch-tex {
    pwsh -ExecutionPolicy Bypass -File "C:\path\to\vault\tex\obsidian\watch-preamble.ps1"
}
```

`C:\path\to\vault`를 실제 vault 경로로 변경. 이후 새 터미널에서 `watch-tex` 실행하면 워처가 백그라운드로 돌면서 자동 빌드.

---

## How it works

```
Edit tex/include/*.tex
        |
        v
watch-preamble.ps1  (FileSystemWatcher on include/**/*.tex)
        |  detects change
        v
build-preamble.ps1
        |  parses main.tex for \input order
        |  concatenates include/**/*.tex in order
        |  writes UTF-8 (no BOM)
        v
preamble.sty  (vault root)
        |
        v
MathJax Preamble Manager  (Obsidian plugin)
        |  hot-reloads on file change
        v
Macros available in all notes instantly -- no Ctrl+R needed
```

`main.tex`이 `\input` 순서를 정의한다. 새 파일을 추가하거나 순서를 바꾸려면
`main.tex`만 수정하면 되며, 빌드 스크립트는 건드리지 않아도 된다.
