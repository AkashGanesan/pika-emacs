;;; pika-bindings.el --- Personal prefix keymaps -*- lexical-binding: t; -*-

(defvar-keymap pika-project-map
  :doc "Personal project commands."
  "b" #'consult-project-buffer
  "c" #'project-compile
  "d" #'project-dired
  "f" #'project-find-file
  "k" #'project-kill-buffers
  "p" #'project-switch-project
  "s" #'consult-ripgrep)

(defvar-keymap pika-compile-map
  :doc "Personal build commands."
  "c" #'compile
  "r" #'recompile)

(defvar-keymap pika-debug-map
  :doc "Personal debugging commands."
  "c" #'pika-cuda-gdb
  "g" #'gdb)

(defvar-keymap pika-git-map
  :doc "Personal Git and GitHub commands."
  "d" #'magit-dispatch
  "f" #'magit-file-dispatch
  "h" #'forge-dispatch
  "l" #'magit-log-current
  "s" #'magit-status)

(defvar-keymap pika-python-map
  :doc "Personal Python development commands."
  "f" #'ruff-format-buffer
  "r" #'lsp-rename
  "s" #'consult-lsp-symbols
  "t" #'pika-python-test
  "u" #'pika-python-uv-sync)

(defvar-keymap pika-hardware-map
  :doc "Personal hardware development commands."
  "c" #'pika-hardware-build
  "f" #'pika-verible-format-buffer
  "l" #'pika-hardware-lint
  "r" #'pika-hardware-regress
  "t" #'pika-hardware-test
  "w" #'pika-hardware-waves)

(defvar-keymap pika-writing-map
  :doc "Personal fiction-writing commands."
  "b" #'pika-writing-open-book
  "c" #'pika-writing-capture-continuity
  "e" #'pika-writing-export-manuscript
  "f" #'pika-writing-focus-mode
  "l" #'org-roam-node-insert
  "o" #'pika-writing-open-outline
  "p" #'pika-writing-spell-check
  "s" #'pika-writing-capture-scene)

(defvar-keymap pika-org-code-map
  :doc "Org source block commands."
  "d" #'org-babel-detangle
  "e" #'org-babel-execute-src-block
  "n" #'org-babel-next-src-block
  "p" #'org-babel-previous-src-block
  "r" #'org-babel-remove-result
  "s" #'org-edit-special
  "t" #'org-babel-tangle)

(defvar-keymap pika-agenda-map
  :doc "Personal Org agenda and capture commands."
  "a" #'org-agenda
  "b" pika-org-code-map
  "c" #'org-capture
  "l" #'org-store-link)

(defvar-keymap pika-notes-map
  :doc "Personal knowledge and citation commands."
  "b" #'org-roam-buffer-toggle
  "c" #'org-roam-capture
  "f" #'org-roam-node-find
  "i" #'org-roam-node-insert
  "o" #'citar-open
  "r" #'org-roam-ref-find
  "s" #'org-roam-db-sync
  "x" #'org-cite-insert)

(keymap-set global-map "C-c p" pika-project-map)
(keymap-set global-map "C-c c" pika-compile-map)
(keymap-set global-map "C-c d" pika-debug-map)
(keymap-set global-map "C-c g" pika-git-map)
(keymap-set global-map "C-c a" pika-agenda-map)
(keymap-set global-map "C-c n" pika-notes-map)
(keymap-set global-map "C-c y" pika-python-map)
(keymap-set global-map "C-c h" pika-hardware-map)
(keymap-set global-map "C-c w" pika-writing-map)

(which-key-add-key-based-replacements
  "C-c p" "project"
  "C-c c" "compile"
  "C-c d" "debug")
(which-key-add-key-based-replacements "C-c g" "git")
(which-key-add-key-based-replacements
  "C-c a" "agenda"
  "C-c a b" "babel"
  "C-c h" "hardware"
  "C-c n" "notes"
  "C-c w" "writing"
  "C-c y" "python")

(provide 'pika-bindings)
;;; pika-bindings.el ends here
