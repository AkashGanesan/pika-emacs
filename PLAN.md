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

### Phase 3 — Org foundation and Zettelkasten — Planned

Implement agenda files, capture templates, Org-roam, Org Cite, Citar, and the knowledge layout above. Begin without visual-decoration packages.

Capture flow:

1. Capture quickly into the inbox.
2. Triage into deletion, an agenda action, a literature note, or a concept note.
3. Link durable concepts to existing notes where a real relationship exists.
4. Connect concepts to hardware, RL, or fiction projects.
5. Record results and decisions back into durable notes.

Acceptance gate:

1. Capture an inbox note without changing buffers.
2. Create and link a concept note.
3. View backlinks.
4. Insert a citation from BibTeX.
5. Promote a note into a project action or manuscript section.

### Phase 4 — Python and RL — Planned

External prerequisites:

- `uv`
- Basedpyright
- Ruff

Implement Python mode, `lsp-mode`, `lsp-pyright`, Corfu completion, Flycheck diagnostics, Ruff commands, test compilation, and project-local environment discovery. Prefer Python modules and Org Babel over notebook integration initially.

Each experiment note should record its paper or concept link, Git commit, command/configuration, seed, artifacts, result, and interpretation.

Acceptance gate:

1. `lsp-mode` starts Basedpyright in a real `uv` project.
2. Completion, definition, references, rename, and workspace symbols work.
3. Flycheck reports a deliberate type error.
4. Ruff formats the buffer.
5. `uv run pytest` executes through `compile` with linked tracebacks.

### Phase 5 — C++, CUDA, RTL, and DV — Planned

Implement in this order:

1. C++ with Clangd and CMake-generated `compile_commands.json`.
2. CUDA with toolkit headers, NVCC, Clangd, and `cuda-gdb`.
3. Verilog/SystemVerilog editing, Verilator, and Verible.
4. Project-local commercial simulator commands where applicable.
5. `verilog-ext` after simpler commands are proven.

Hardware projects should expose boring commands such as:

```text
make lint
make compile
make test TEST=<name> SEED=<seed>
make regress
make waves TEST=<name>
```

Emacs invokes these through `compile`; it does not duplicate simulator file lists or flags.

Acceptance gate:

- C++ and CUDA navigation use real compilation databases.
- Build and lint diagnostics link to source.
- GDB and `cuda-gdb` start against debug targets.
- SystemVerilog navigation works across representative packages, interfaces, modules, and classes.
- One named and seeded simulation runs from Emacs.
- Generated waveforms open successfully.

### Phase 6 — Fiction workflow — Planned

Use Org files for manuscript structure and Org-roam for worldbuilding and research. Do not fragment manuscript prose into atomic notes.

Markdown editing and the dark theme are already available. The structured fiction
workflow, spell checking, focused prose presentation, and export remain planned.

Suggested manuscript layout:

```text
manuscript/
  book.org
  outline.org
  chapters/
  exports/
```

Implement prose presentation, spell checking, scene and continuity capture templates, links to characters/settings, and multi-file export.

Acceptance gate:

1. Capture a scene idea while editing a chapter.
2. Link it to character and setting notes.
3. Run spell checking.
4. Export a multi-file sample chapter with correct ordering and formatting.

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
