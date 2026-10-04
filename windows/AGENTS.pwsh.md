# Windows tool preferences

This machine uses PowerShell 7 (`pwsh`), not Windows PowerShell 5.1.

Prefer these tools (already installed):

- Use `rg` instead of `findstr`, `Select-String`, or recursive manual scanning.
- Use `fd` instead of `Get-ChildItem -Recurse` for locating files.
- Use `jq` for JSON transformations.
- Use `fzf` for interactive filtering only when appropriate.
- Use GNU/uutils commands such as `cat`, `head`, `tail`, `sort`, `uniq`, `wc`, `touch`, `cp`, `mv`, and `rm` when they simplify the command.
- Use native PowerShell cmdlets when they provide structured object output.

Shell rules:

- Assume PowerShell 7 syntax.
- Do not use `cmd.exe` syntax unless explicitly required.
- Do not assume Unix utilities exist; verify them once before use.
- Avoid aliases whose behavior differs from PowerShell and Unix conventions.
- Prefer commands with machine-readable output, such as JSON.
- Do not invoke `powershell.exe`; use `pwsh`.

Concurrency and job rules:

- When running multiple PowerShell tasks concurrently, prefer `Start-ThreadJob` over `Start-Job`.
- Avoid `Start-Job` unless process isolation is explicitly required.
- Do not spawn multiple `pwsh` processes for simple parallel execution.
- Prefer thread-based jobs, runspace-based parallelism, or native process execution when appropriate.
- Use `ForEach-Object -Parallel` for data-parallel workloads when it provides a simpler solution.
- Keep the number of concurrent jobs bounded to avoid unnecessary resource usage.
- Use `Start-Process` only when a separate OS process is intentionally required.
