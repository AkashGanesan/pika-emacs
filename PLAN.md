# Emacs Migration Plan

## Goal

Replace Spacemacs with a maintainable personal configuration supporting:

- Git and GitHub
- Python and state-of-the-art reinforcement-learning research
- C++, CUDA, RTL, and design verification
- Org agenda, citations, and a Zettelkasten knowledge workflow
- Science-fiction planning and long-form writing

The migration remains reversible until the final cutover. The custom configuration runs beside the existing Spacemacs installation through `--init-directory`.

## Decisions

- Keep Emacs editing style; do not reproduce Spacemacs or add Evil.
- Use built-in `package.el` and `use-package`.
- Prefer built-in Emacs facilities before external packages.
- Use `lsp-mode` as the only language-server client; do not configure Eglot.
- Use project-local tools and build descriptions instead of global include paths or command flags.
- Keep ordinary Org agenda files separate from the Org-roam knowledge base.
- Begin with plain Emacs Lisp rather than a tangled literate configuration.
- Add optional presentation and integration packages only after the underlying workflow works.

## Target architecture

```text
early-init.el
init.el
lisp/
  pika-core.el
  pika-completion.el
  pika-bindings.el
  pika-development.el     Git, GitHub, LSP, Python, C++, CUDA
  pika-hardware.el        Verilog, SystemVerilog, lint, simulation
  pika-org.el             agenda, capture, citations, Org-roam
  pika-writing.el         prose presentation and manuscript export
snippets/
```

Only the modules required by completed phases should exist. Empty scaffold modules are intentionally avoided.

## Package direction

### Core completion

- Vertico
- Orderless
- Marginalia
- Consult
- Embark and Embark-Consult
- Corfu
- Cape
- Which-Key

### Projects and source control

- Built-in `project.el`
- Magit
- Forge

### Development

- `lsp-mode`
- `lsp-ui`, initially restrained
- `consult-lsp`
- Flycheck
- Basedpyright through `lsp-pyright`
- Clangd for C++ and CUDA
- Ruff for Python linting and formatting
- Built-in `compile`, GDB, and later `dap-mode` only if needed

Corfu should consume LSP completion through the completion-at-point API. LSP file watchers must exclude environments, build trees, datasets, checkpoints, simulator output, and waveforms.

### Hardware

- Built-in `verilog-mode`
- Verilator for portable lint and simulation where appropriate
- Verible for formatting and language-server support
- A SystemVerilog server selected by testing against real RTL and UVM code
- `verilog-ext` only after the basic lint, compile, and simulation workflow is stable

### Knowledge management

- Org
- Org-roam
- Built-in Org Cite
- Citar

### Writing

- Markdown Mode for Markdown and GitHub-flavored Markdown (available)
- Built-in Modus Vivendi dark theme (available)
- Olivetti
- Jinx or Flyspell
- Org export to the format required by collaborators or publishers

Optional packages such as `org-roam-ui`, `org-download`, `pdf-tools`, `org-noter`, `dap-mode`, and snippet engines remain deferred until a concrete need appears.

## Knowledge layout

```text
~/org/
  agenda/
    inbox.org
    projects.org
    someday.org
  roam/
    references/
    concepts/
    hardware/
    rl/
    fiction/
  bibliography/
    references.bib
    files/
  manuscript/
```

Directories provide broad storage boundaries. Links, aliases, tags, citations, and search provide discovery.

Initial note types:

- Fleeting note: raw observation to process or delete
- Literature note: source-specific claims written in the user's own words
- Concept note: one durable idea and its relationships
- Project note: goal, status, decisions, and next actions
- Experiment note: hypothesis, command/configuration, result, and interpretation
- Fiction note: character, location, technology, scene, or theme

Use immutable timestamp-based Org IDs. Titles may change without breaking links.

## Migration phases

### Phase 0 — Preserve and establish a baseline — Complete

- Initialized `/home/pika/learn/pika-emacs` as a Git repository.
- Kept `~/.emacs.d` and `~/.spacemacs` unchanged.
- Isolated packages, customizations, backups, auto-saves, and caches under ignored paths.
- Established side-by-side launch:

```bash
emacs --init-directory /home/pika/learn/pika-emacs
```

Acceptance gate: Spacemacs remains available and the custom configuration launches independently. Passed.

### Phase 1 — Core Emacs — Complete

Implemented:

- Package bootstrap
- Core file and editing defaults
- Vertico, Orderless, Marginalia, Consult, and Embark
- Corfu and Cape
- `project.el`
- Which-Key
- Futuristic city startup dashboard with recent projects and files
- Personal project, compile, and debug prefixes

Acceptance gate: isolated daemon startup, completion activation, project recognition, and keymap behavior. Passed.

### Phase 2 — Git and GitHub — Complete

Implemented and verified:

- Magit status and source-control commands
- Forge tracking and API synchronization for `AkashGanesan/pika-emacs`
- Public GitHub remote at `https://github.com/AkashGanesan/pika-emacs`
- Encrypted token storage in `~/.authinfo.gpg`
- Passphrase-protected local GPG identity
- Secure `omp-github` launcher for the GitHub plugin
- Generated Forge and Transient state under ignored `var/` paths
- The `C-c g` Git and GitHub command map

The optional `gh` CLI is not installed; Magit, Forge, and the GitHub plugin cover
the current workflow.

### Phase 3 — Org foundation and Zettelkasten — Complete

Implemented and verified:

- Agenda files for inbox, projects, and someday items
- Capture templates for tasks, fleeting notes, projects, and deferred ideas
- Org-roam autosync with its SQLite database under ignored `var/` state
- Permanent-note templates for concepts, literature, hardware, RL, fiction,
  projects, and experiments
- Org Cite with Citar and a BibTeX library
- Attached-reference storage outside the configuration repository
- Backlink discovery and completion throughout Org buffers
- Org Babel editing, explicit execution, result management, and tangling
- Executable Emacs Lisp, Python, shell, C, and C++ blocks
- Editable and tangleable Verilog and SystemVerilog blocks
- `C-c a` agenda and Babel commands and `C-c n` knowledge commands

Behavioral verification captured an inbox task, rendered it in the agenda,
created linked Markov decision process and reinforcement-learning notes,
observed the backlink, inserted the Sutton and Barto citation, executed Python
through Org Babel, and tangled the source to a standalone file. Temporary
capture and code-smoke artifacts were removed afterward.

### Phase 4 — Python and RL — Complete

External prerequisites:

- `uv`
- Basedpyright
- Ruff

Implemented and verified:

- Python mode with `lsp-mode` and `lsp-pyright`
- Basedpyright completion, definitions, references, rename, workspace symbols,
  and type diagnostics
- Corfu completion through LSP's completion-at-point function
- Flycheck diagnostics with Ruff linting after LSP diagnostics
- Project-local `.venv` discovery for Python shells and subprocesses
- Explicit `uv sync` dependency synchronization with environment refresh
- Ruff buffer and region formatting
- `uv run pytest` through compilation mode
- File-watcher exclusions for environments, build trees, datasets,
  checkpoints, simulator output, and waveforms
- Restrained `lsp-ui` presentation with documentation popups and sidelines off
- The `C-c y` Python command map

Behavioral verification used a real temporary `uv` project. Basedpyright
provided completion, definition and reference locations, a cross-file rename,
workspace symbols, and a deliberate type error through Flycheck. Ruff
formatted the buffer, synchronized a declared dependency into the project
`.venv`, imported it through the environment selected by Emacs, and ran
`uv run pytest` with linked compilation output and one passing test.

Experiment notes record their paper or concept link, Git commit,
command/configuration, seed, artifacts, result, and interpretation.

### Phase 5 — C++, CUDA, RTL, and DV — Complete

External prerequisites:

- Clangd and CMake
- CUDA toolkit, NVCC, and `cuda-gdb`
- Verible and Verilator
- A project-selected simulator and waveform viewer

Implemented and verified:

1. C++ and CUDA navigation use Clangd with real CMake-generated
   `compile_commands.json` databases.
2. C++ and CUDA debug builds run through project-local CMake targets; GDB and
   `cuda-gdb` start against the resulting executables.
3. Verilog and SystemVerilog buffers use Verible for LSP navigation across
   packages, interfaces, modules, and classes, plus Verible buffer formatting.
4. Hardware commands run simulator-independent project targets through
   compilation mode:

   ```text
   make lint
   make compile
   make test TEST=<name> SEED=<seed>
   make regress
   make waves TEST=<name>
   ```

5. Commercial simulator selection, file lists, flags, libraries, licenses, and
   environment setup remain in project Makefiles. The Emacs commands require no
   simulator-specific branch.
6. `verilog-ext` was evaluated but not added: its LSP, formatting, linting,
   compilation, and navigation features currently duplicate the verified
   smaller configuration.

Behavioral verification used temporary C++, CUDA, and SystemVerilog projects.
Clangd resolved definitions and references from real compilation databases;
CMake debug builds completed; GDB and `cuda-gdb` launched; compiler diagnostics
navigated to source; Verible resolved cross-file package, interface, module, and
class symbols and formatted a buffer. A named simulation ran with seed 42,
three regression seeds passed, and Surfer loaded the generated VCD in headless
server mode.

### Phase 6 — Fiction workflow — Complete

Manuscript prose remains in ordered Org files under `~/org/manuscript/`;
characters, settings, worldbuilding, and research remain linked Org-roam notes
under `~/org/roam/fiction/`.

Implemented and verified:

1. Olivetti and variable-pitch presentation provide a reversible focused prose
   view without changing manuscript text.
2. Flyspell and explicit whole-buffer checking use Aspell in Org and Markdown
   buffers.
3. Scene and continuity captures preserve a link to the current chapter and
   provide fields for character, setting, purpose, established facts, and
   follow-up.
4. Dedicated Org-roam templates create tagged character and setting notes;
   normal Org-roam insertion links them from captures and chapters.
5. `book.org` owns chapter order through Org `#+include:` directives. Export
   expands those files into `exports/book.html`.
6. The `C-c w` map opens the manuscript and outline, captures writing notes,
   inserts fiction links, toggles focused presentation, checks spelling, and
   exports the manuscript.

Behavioral verification used a temporary two-chapter manuscript. Emacs enabled
and disabled focused presentation, completed an Aspell pass, captured a scene
from the first chapter with character and setting links, and exported both
chapters to HTML in the order declared by `book.org`.

### Phase 7 — Cutover — Complete

The default-startup cutover was completed early by user choice:

1. The Spacemacs checkout was moved to `~/.emacs.d-spacemacs`.
2. `~/.emacs.d` now links to `/home/pika/learn/pika-emacs`.
3. Normal `emacs` startup loads pika-emacs without `--init-directory`.
4. The Spacemacs backup remains available until its rollback value is gone.

## Maintenance rules

1. Add one package only for one observed workflow gap.
2. Prefer variables, hooks, and package-native APIs over advice.
3. Use named functions where they improve debugging.
4. Keep global configuration tool-oriented and project configuration build-oriented.
5. Document external executable prerequisites beside their integrations.
6. Never commit secrets, caches, generated customizations, large artifacts, or Org-roam's SQLite database.
7. Verify batch loading after every configuration change.
8. Verify significant changes against the actual interactive workflow.
9. Diagnose startup failures with `--debug-init`; never suppress them.
10. Periodically remove packages and settings no longer tied to real workflows.
