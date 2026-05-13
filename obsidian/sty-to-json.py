#!/usr/bin/env python3
"""Convert preamble.sty (\\newcommand / \\def) to:
  1. macros.json — generic mdmath-compatible map
  2. .vscode/settings.json — `markdown.extension.katex.macros` for VSCode's
     markdown-all-in-one extension (Ctrl+Shift+V native preview).

If .vscode/settings.json already exists, the macros key is merged in (other
keys preserved). If parsing fails (e.g. JSONC with comments), the snippet is
written to .vscode/markdown-katex-macros.snippet.json instead.
"""
import json
import re
import sys
from pathlib import Path

PATTERN = re.compile(r'^\s*\\(?:newcommand|def)\\([a-zA-Z][a-zA-Z0-9]*)\s*\{(.*)\}\s*$')
KEY = 'markdown.extension.katex.macros'


def parse_macros(sty_path):
    macros = {}
    for line in sty_path.read_text().splitlines():
        m = PATTERN.match(line)
        if m:
            macros[f'\\{m.group(1)}'] = m.group(2)
    return macros


def write_json(path, data):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(data, indent=2, ensure_ascii=False) + '\n', encoding='utf-8')


def merge_vscode_settings(settings_path, macros):
    if not settings_path.exists():
        write_json(settings_path, {KEY: macros})
        return f'created {settings_path} ({len(macros)} macros)'
    try:
        existing = json.loads(settings_path.read_text(encoding='utf-8'))
    except json.JSONDecodeError:
        snippet = settings_path.parent / 'markdown-katex-macros.snippet.json'
        write_json(snippet, {KEY: macros})
        return (f'existing {settings_path.name} not pure JSON — wrote {snippet.name}; '
                f'paste its contents into settings.json manually')
    existing[KEY] = macros
    write_json(settings_path, existing)
    return f'merged into {settings_path} ({len(macros)} macros)'


def main():
    if len(sys.argv) != 4:
        print(f'Usage: {sys.argv[0]} <input.sty> <macros.json> <.vscode/settings.json>',
              file=sys.stderr)
        sys.exit(1)
    sty, macros_out, vscode_out = map(Path, sys.argv[1:4])
    macros = parse_macros(sty)
    write_json(macros_out, macros)
    print(f'Built {macros_out.name}: {len(macros)} macros -> {macros_out}')
    print(f'VSCode settings: {merge_vscode_settings(vscode_out, macros)}')


if __name__ == '__main__':
    main()
