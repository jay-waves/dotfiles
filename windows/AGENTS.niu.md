# Windows shell environment

This Windows machine uses Niubash as its Bash environment. 

For every `exec_command` call, always set:

    shell = "bash"

Use the default sandbox unless escalation is genuinely required.

The `bash.exe` on PATH forwards commands to Niubash. Use Bash syntax directly.

Do not wrap commands in `niu -c`, PowerShell, or `cmd.exe` unless explicitly
required.

## Environment

Available on PATH:

- niu.exe / Bash
- Go
- Node.js
- CPython
- rg, fd, jq
- niubash Unix tools such as ls, cat, grep, find, sed, head, tail, sort, wc, cp, mv, and rm

Assume:

- Bash syntax and shell semantics.
- Windows filesystem and process semantics.
- Windows-native executables can be invoked directly.
- Unix tools are avialable on PATH
- WSL, MSYS2, Cygwin, and Git Bash are not assumed.

## Shell rules

- Use Bash variables, pipelines, redirections, `&&`, `||`, and `$(...)`.
- Quote paths and variable expansions by default.
- Do not use PowerShell syntax or cmdlets.
- Do not invoke `pwsh`, `powershell.exe`, or `cmd.exe` unless explicitly required.

## Paths

- Prefer `C:/Users/name/project` or relative paths like `./src`.
- Do not use WSL paths such as `/mnt/c/...`.

## Other Details !!

- Prefer `C:/Users/name/project` or relative paths like `./src`.
- Do not use WSL paths such as `/mnt/c/...`.
- Use LF (`\n`) when creating or editing text files. Do not write CRLF.
- When writing files with Python, explicitly set `newline="\n"`,
  or use `write_bytes()` with content normalized to LF

<!-- [features] -->
<!-- unified_exec = true -->
<!-- codex --no-daemon -->
