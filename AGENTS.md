# Repository Guidance

## Scope

These instructions apply to the entire `pika-emacs` repository.

## Purpose

Maintain a small Emacs configuration for:

- Git and GitHub workflows
- Python and reinforcement-learning research
- C++, CUDA, RTL, and design verification
- Org agenda, citations, and a Zettelkasten workflow
- Long-form science-fiction writing

Correctness and debuggability take precedence over startup micro-optimizations or visual decoration.

## Architecture

- `early-init.el` contains only settings that must run before package initialization.
- `init.el` owns package archives, `use-package` policy, generated-state paths, and module loading.
- Each file under `lisp/` owns one coherent workflow and provides a matching feature.
- Keep package-specific configuration in the owning module; do not turn `init.el` into a second configuration module.
- Do not create a file per package. Split a module only when it contains independently maintainable workflows.

Planned modules are documented in `PLAN.md`. Create them only when implementing their phase; do not add empty scaffolding.

## Emacs Lisp conventions

- Enable lexical binding in every Emacs Lisp file.
- Prefer built-in APIs, named functions, hooks, and package-supported customization points.
- Prefer `use-package :hook`, `:bind`, and `:custom` over large `:config` bodies.
- Avoid advice unless the target behavior cannot be configured through a supported API.
- Personal global bindings belong under the `C-c` prefix and in `pika-bindings.el`.
- Preserve package-native bindings unless there is a demonstrated conflict.
- Use `lsp-mode`, not Eglot. Do not configure both clients.
- Keep compiler flags, include paths, simulator arguments, and environment selection in project configuration.

## Package and generated state

- Use built-in `package.el` and `use-package`; do not add another package manager.
- Prefer GNU ELPA or NonGNU ELPA packages over MELPA copies when available.
- External executables remain explicit prerequisites; never hide missing tools with silent fallbacks.
- Never commit `var/`, `eln-cache/`, generated `custom.el`, package contents, credentials, waveform data, build products, or machine-local paths in Lisp.

## Change discipline

- Implement migration phases incrementally and preserve side-by-side Spacemacs operation until cutover.
- Add one package only for one observed workflow requirement.
- Remove obsolete configuration when replacing a package or workflow; do not retain compatibility aliases.
- Update `README.md` and `PLAN.md` when a user-visible workflow or migration status changes.
- Never modify `~/.spacemacs` or the Spacemacs checkout as part of this repository.

## Verification

For every configuration change:

1. Load `early-init.el` and `init.el` in isolated batch mode.
2. Launch Emacs with this repository as `--init-directory` for significant behavioral changes.
3. Exercise the changed command or workflow rather than checking only that a feature is loaded.
4. Confirm generated files remain under ignored directories.

Batch smoke command:

```bash
emacs --batch \
  --init-directory /home/pika/learn/pika-emacs \
  --load /home/pika/learn/pika-emacs/early-init.el \
  --load /home/pika/learn/pika-emacs/init.el \
  --eval '(princ "configuration-loaded\n")'
```
