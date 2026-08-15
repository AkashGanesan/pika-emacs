# pika-emacs

A small, maintainable Emacs configuration for software development, RTL and design verification, reinforcement-learning research, Org-based knowledge management, and science-fiction writing.

The configuration is the default Emacs setup. The previous Spacemacs checkout is preserved at `~/.emacs.d-spacemacs`.

## Status

Migration phases 0, 1, 2, 3, and the default-startup cutover are complete.

- Isolated configuration repository and generated state
- Core editing and file-management defaults
- `package.el` and built-in `use-package`
- Vertico, Orderless, Marginalia, Consult, and Embark
- Corfu and Cape completion
- `project.el` workflows
- Which-Key and personal prefix maps
- Markdown and GitHub-flavored Markdown editing
- Built-in Modus Vivendi dark theme
- Maximized GUI frames at startup
- Magit for Git workflows
- Forge for GitHub issues and pull requests
- Encrypted credentials through `~/.authinfo.gpg`
- Org agenda and capture workflow
- Org-roam Zettelkasten with backlinks
- Org Cite and Citar bibliography
- Org Babel execution and tangling for Emacs Lisp, Python, shell, C, and C++

See [`PLAN.md`](PLAN.md) for the remaining migration plan.

Repository: <https://github.com/AkashGanesan/pika-emacs>

## Requirements

- Emacs 30 is the tested version; the configuration uses modern Emacs APIs.
- Git is required for project detection and Magit.
- GnuPG is required for encrypted GitHub credentials.
- Internet access is required on the first launch to install ELPA packages.
- The `gh` CLI is optional and is not currently installed.
- Python 3 and C/C++ compilers are required to execute the configured Org Babel languages.

## Run

```bash
emacs
```

Packages and generated state are stored under `var/` and are not committed.

`~/.emacs.d` links to this repository. The preserved Spacemacs checkout is not loaded by normal Emacs startup.

## Layout

```text
early-init.el              settings required before package initialization
init.el                    package bootstrap and module loading
lisp/pika-core.el          editing, persistence, and project defaults
lisp/pika-completion.el    minibuffer and in-buffer completion
lisp/pika-development.el  Magit, Forge, credentials, and development tools
lisp/pika-org.el          agenda, Zettelkasten, citations, and code blocks
lisp/pika-bindings.el      personal prefix keymaps
lisp/pika-writing.el      Markdown and prose-editing support
PLAN.md                    phased migration plan
AGENTS.md                  repository maintenance rules
```

Future language, hardware, and remaining long-form writing support will be added as focused modules rather than expanding `init.el`.

## Main bindings

| Binding     | Action                                              |
|-------------|-----------------------------------------------------|
| `C-s`       | Search the current buffer with Consult              |
| `C-x b`     | Switch buffers with Consult                         |
| `C-.`       | Act on the current completion candidate with Embark |
| `M-/`       | Complete from buffer text with Cape                 |
| `C-c f`     | Complete a file name with Cape                      |
| `C-c p f`   | Find a file in the current project                  |
| `C-c p b`   | Switch project buffers                              |
| `C-c p s`   | Search the current project with ripgrep             |
| `C-c p c`   | Compile the current project                         |
| `C-c c c`   | Run `compile`                                       |
| `C-c c r`   | Run `recompile`                                     |
| `C-c d g`   | Start GDB                                           |
| `C-c g s`   | Open Magit status                                   |
| `C-c g d`   | Open the Magit dispatch                             |
| `C-c g f`   | Open the Magit file dispatch                        |
| `C-c g l`   | Show the current branch log                         |
| `C-c g h`   | Open the Forge dispatch                             |
| `C-c a a`   | Open the Org agenda                                 |
| `C-c a c`   | Capture a task, note, project, or someday item      |
| `C-c a b e` | Execute the Org source block at point               |
| `C-c a b s` | Edit the Org source block at point                  |
| `C-c a b t` | Tangle source blocks                                |
| `C-c n f`   | Find or create an Org-roam note                     |
| `C-c n i`   | Insert an Org-roam link                             |
| `C-c n b`   | Toggle the Org-roam backlinks buffer                |
| `C-c n c`   | Open Org-roam capture                               |
| `C-c n o`   | Open a bibliography item with Citar                 |
| `C-c n x`   | Insert an Org citation                              |

Press a prefix and pause to display its Which-Key help.

## Org workspace

Personal Org data lives outside the configuration repository:

```text
~/org/
├── agenda/               inbox, projects, and someday lists
├── roam/                 linked permanent notes
│   ├── concepts/
│   ├── experiments/
│   ├── fiction/
│   ├── hardware/
│   ├── projects/
│   ├── references/
│   └── rl/
├── bibliography/         BibTeX metadata and attached files
└── manuscript/           chapters and exports
```

Capture fleeting material with `C-c a c`, then promote durable ideas with
`C-c n f`. Org-roam templates cover concepts, literature, hardware, RL,
fiction, projects, and experiments. The knowledge base begins with linked
Markov decision process and reinforcement-learning notes.

The bibliography at `~/org/bibliography/references.bib` starts with Sutton and
Barto's *Reinforcement Learning: An Introduction*. Citar drives Org Cite
selection and attached-file lookup.

Org Babel keeps evaluation explicit: Emacs asks before executing code. Enabled
languages are Emacs Lisp, Python, shell, C, and C++. Verilog and SystemVerilog
blocks can be edited and tangled but are not executed. Use `C-c a b` for source
block navigation, editing, execution, result removal, and tangling.

## GitHub authentication

The GitHub token is encrypted at rest in `~/.authinfo.gpg` with the local,
passphrase-protected GPG key. Forge reads that file through Emacs
`auth-source`; the token is never stored in this repository.

Start OMP with the secure launcher so the GitHub plugin receives the token only
in its process environment:

```bash
omp-github
```

The launcher at `~/.local/bin/omp-github` decrypts the token through
`auth-source`, exports it for the child OMP process, and does not persist a
plaintext copy. Use `C-c g s` for Magit and `C-c g h` for Forge.

## Verify startup

Batch mode does not load a user init automatically, so load both startup files explicitly:

```bash
emacs --batch \
  --init-directory /home/pika/learn/pika-emacs \
  --load /home/pika/learn/pika-emacs/early-init.el \
  --load /home/pika/learn/pika-emacs/init.el \
  --eval '(princ "configuration-loaded\n")'
```

For normal behavioral verification, launch `emacs` and exercise file search, completion, project navigation, compilation, and source control.

## Configuration policy

- Prefer built-in Emacs facilities before external packages.
- Use `lsp-mode`, not Eglot, for language-server integration.
- Keep build flags and commands in projects, not global Emacs Lisp.
- Never commit credentials, package caches, generated customizations, or machine-local state.
- Add packages only for an observed workflow need.
