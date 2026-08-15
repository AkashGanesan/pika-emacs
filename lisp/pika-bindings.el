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
  "g" #'gdb)

(defvar-keymap pika-git-map
  :doc "Personal Git and GitHub commands."
  "d" #'magit-dispatch
  "f" #'magit-file-dispatch
  "h" #'forge-dispatch
  "l" #'magit-log-current
  "s" #'magit-status)

(keymap-set global-map "C-c p" pika-project-map)
(keymap-set global-map "C-c c" pika-compile-map)
(keymap-set global-map "C-c d" pika-debug-map)
(keymap-set global-map "C-c g" pika-git-map)

(which-key-add-key-based-replacements
  "C-c p" "project"
  "C-c c" "compile"
  "C-c d" "debug")
(which-key-add-key-based-replacements "C-c g" "git")

(provide 'pika-bindings)
;;; pika-bindings.el ends here
