# Workspace-wide instructions

> **Workspace purpose: Excel VBA and Python project development.** Each project under `Projects/` owns its source code, documentation, and Git history as one unit.

- Scaffold only VBA-Python projects from `Projects/_Template_Combined`, always including both `Pysource/` and `VBsource/`. Do not add single-language creation modes or project-type selection.
- Follow the conventions of the project being changed. Keep changes focused on the request, readable, and consistent with nearby code.
- Before editing, read the README for the target project and inspect relevant source, configuration, and tests. Read other projects' READMEs only when the task spans those projects or shared behavior.
- When answering a question about either `VBsource/` or `Pysource/`, inspect both directories in the target project before responding. Trace relevant VBA-Python interactions across both sides when applicable, and state clearly when either directory or the relevant source is unavailable.
- Use `Pysource/` for Python, `VBsource/<workbook name>/` for exported VBA, and `Sandbox/` for prototypes. Preserve these exact names. Do not mix unverified prototypes with production exports or imply that prototype code is already deployed.
- Keep one Git repository at the project root. Do not create nested repositories or restructure projects unless requested or necessary for the task.
- Keep shared tools and standard VS Code tasks at the workspace root. Normally work with the whole workspace open; nested project `.vscode/settings.json` files do not configure the parent workspace. Follow project-specific interpreter and dependency requirements rather than assuming all projects use the same environment.
- Do not import VBA modules or code into an Excel workbook unless the user explicitly requests that operation. Editing exported source files does not update the code inside the workbook.
- After code changes, run the smallest relevant existing validation and report what was checked and any checks that could not be run.

## Approval before Excel operations

- Before starting Excel, opening a workbook, running a macro, or modifying or saving a live workbook, ask for explicit permission in Japanese and wait for an affirmative reply. This separate confirmation is required even if the original task requests the operation; a general request to investigate or improve the workspace is not permission.
- Make the request unmistakable as a permission question, not a notice. State the exact workbook path, planned operation, relevant module/macro, and whether workbook contents will change. For example: 「【許可の確認】Excelを起動して、ブック『<フルパス>』を開いてもよいですか？ 読み取りのみで、マクロの実行や変更・保存は行いません。許可をいただくまで操作しません。」
- Permission to open or read does not authorize macro execution, code import, modification, or saving. Obtain separate permission before expanding scope. Never substitute a similarly named workbook or component.
- This applies to tools, tasks, scripts, delegated work, and COM automation, including Python code and read-only tools that may launch Excel automatically. When behavior is uncertain, inspect offline files first. Without approval, limit work to offline source, configuration, and documentation and disclose runtime validation limits.

## VBA development

Apply these rules when creating or changing VBA source, including prototypes.

- Follow the target project's README and existing VBA style and structure. Keep changes focused on the requested behavior; do not assume an exported file is the only copy of the code.
- Treat the workbook as the runtime artifact. Keep production exports under `VBsource/<workbook name>/` and unverified prototypes in `Sandbox/`. Preserve UserForm `.frx` files beside their `.frm` files.
- Do not import or apply code, change workbook contents, or run macros unless explicitly requested, and follow the separate Japanese permission-confirmation procedure above before any Excel operation, including opening or reading a workbook. Editing exported source alone does not update the workbook.
- Before generating code that references a worksheet, defined name, or form control, confirm the object exists. If offline evidence is insufficient, obtain permission for workbook inspection or identify the unresolved prerequisite instead of guessing. Investigate relevant formulas, data validation, and conditional formatting as well as VBA.
- For live code updates through Excel VBA Sync tools, preview with a dry run before the confirmed write. If exported source is maintained, re-export the changed module immediately afterward. A code write does not save the workbook; report its save state accurately.
- Distinguish static source checks from Excel/VBE compilation and runtime validation. For VBA-to-Python changes, verify the calling contract on both sides and disclose any untested workbook behavior.
- Limit each logical statement to at most 24 line-continuation markers (` _`, a space followed by an underscore; up to 25 physical lines). If a statement would exceed this limit, split it into intermediate variables or smaller statements; prefer readable code over approaching the limit.

## Python development

Apply these rules when creating or changing Python source, including prototypes.

- Target Python 3.10 or later. Verify changes with Python 3.13 when that interpreter is available.
- Use four spaces for indentation. Add type hints to public functions where practical.
- Add Japanese docstrings in triple double quotes to newly created or modified modules, classes, and functions, including private ones. Describe their purpose or behavior.
- Keep each function focused and reasonably short. Add brief comments only when the logic is not self-explanatory.
- Use the standard-library `logging` module, rather than `print`, to report errors and warnings.
- Follow the existing naming conventions: `lowerCamelCase` for parameters, local/member variables; `UpperCamelCase` for classes and functions; `UPPER_SNAKE_CASE` for constants; prefix private variables and functions with `_`.
- Prefer the standard library over external packages unless the project or user requires otherwise. Before changing dependencies or behavior, check the target project's README, `requirements.txt`, and relevant tests.
- Use the selected installed system Python by default, without automatic virtual-environment creation or package installation. Respect project-specific environment requirements. Confirm the interpreter used for validation and report it.
- Keep production Python under `Pysource/`, prototypes under `Sandbox/`, and dependency declarations at the project root.
- For VBA callers, verify arguments, working directory, input/output formats, exit codes, and error reporting. Avoid PC-specific hardcoded paths and changes to a shared Python environment outside the requested scope.
- Python scripts that launch Excel or use COM to open, read, modify, or save workbooks require the same prior Japanese permission confirmation as direct Excel tools. Do not run them for validation before approval; report the resulting runtime validation limits.

## Cross-language changes and handoff

- When changing VBA-to-Python integration, verify the entry point, interpreter, arguments, working directory, input/output format, and error reporting on both sides. Prefer paths relative to the project or workbook over PC-specific paths in source code. Do not install dependencies or change a shared Python environment without checking the project's requirements and the requested scope.
- Distinguish source checks, Python tests, and Excel/VBE compile or runtime checks. Passing static checks or Python tests does not establish that a workbook macro works. Report untested boundaries explicitly.
- Do not claim automatic activity logging or memory generation unless the required tools are configured and their results have been verified.
- If a project already uses `CopilotActivityLog.md` and `CopilotMemory.md`, follow its README. Keep new activity entries uniquely identified and `copilot_context: false`; only the user changes them to `true` or `discard`. Do not overwrite history, delete entries, or claim memory was generated without performing and verifying the operation. Never record secrets or unrelated personal data.

## Troubleshooting reports

- Before investigating a concrete problem, search existing reports for the target project and relevant shared area. Check `Defects/` and `Maintenance/` subfolders when present. Verify historical guidance against current code, workbooks, configuration, and environment rather than applying it blindly.
- Once a concrete problem is fixed and verified, record the confirmed cause, resolution, and validation in the appropriate report. Check for the same root cause first; add a dated note when a recurrence adds useful information instead of duplicating or replacing history. Clearly label guesses and unverified results.
- For report creation, organization, updates, or investigation summaries, follow the instruction file `instructions/Report Writing Rules.instructions.md`. Do not relocate or rename existing reports merely to apply the new rules.

These English-language instructions are the authoritative workspace guidance for Copilot.
