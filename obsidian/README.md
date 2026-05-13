# Obsidian Integration

Scripts and instructions for using `tex_symbols` macros in Obsidian via the
**MathJax Preamble Manager** plugin.

## Contents

- `build-preamble.ps1` / `build-preamble.sh` — concatenates `../include/**/*.tex` into `preamble.sty` at vault root
- `watch-preamble.ps1` / `watch-preamble.sh` — file watcher that auto-rebuilds on `.tex` change

Use the `.ps1` pair on Windows (PowerShell `FileSystemWatcher`) and the `.sh`
pair on Linux/macOS (`inotifywait`). Both write the same `preamble.sty`.

---

## Setup

### 1. Clone `tex_symbols` as submodule into vault

```bash
git submodule add https://github.com/gunheeShin/tex_symbols.git tex
```

### 2. Initial build

**Windows (PowerShell)**:

```powershell
pwsh -ExecutionPolicy Bypass -File tex/obsidian/build-preamble.ps1
```

**Linux / macOS (bash)**:

```bash
bash tex/obsidian/build-preamble.sh
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

### 5. Auto-rebuild watcher

저장할 때마다 `preamble.sty`를 자동 재생성한다. 한 번 띄워두면 매크로
편집 후 Obsidian으로 돌아가면 즉시 반영된다.

**Windows (PowerShell `$PROFILE`에 추가)**:

```powershell
# tex_symbols watcher
function watch-tex {
    pwsh -ExecutionPolicy Bypass -File "C:\path\to\vault\tex\obsidian\watch-preamble.ps1"
}
```

`C:\path\to\vault`를 실제 vault 경로로 변경. 새 터미널에서 `watch-tex` 실행.

**Linux / macOS (bash)**:

먼저 `inotify-tools` 설치 (한 번만):

```bash
sudo apt install inotify-tools          # Debian/Ubuntu
# brew install fswatch                  # macOS는 fswatch 권장 (스크립트 수정 필요)
```

실행:

```bash
bash tex/obsidian/watch-preamble.sh
```

`~/.bashrc` 또는 `~/.zshrc`에 alias 추가 가능:

```bash
alias watch-tex='bash ~/Documents/Obsidian\ Vault/tex/obsidian/watch-preamble.sh'
```

---

## How it works

```
Edit tex/include/*.tex
        |
        v
watch-preamble.{ps1|sh}   (FileSystemWatcher / inotifywait on include/**/*.tex)
        |  detects change (debounced 500ms)
        v
build-preamble.{ps1|sh}
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
