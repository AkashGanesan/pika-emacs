;;; pika-core.el --- Core editing and project defaults -*- lexical-binding: t; -*-

(defconst pika-backup-directory
  (expand-file-name "backups/" pika-var-directory))
(defconst pika-auto-save-directory
  (expand-file-name "auto-save/" pika-var-directory))

(make-directory pika-backup-directory t)
(make-directory pika-auto-save-directory t)

(setq inhibit-startup-screen t
      initial-scratch-message nil
      ring-bell-function #'ignore
      use-short-answers t
      sentence-end-double-space nil
      require-final-newline t
      confirm-kill-emacs #'y-or-n-p
      backup-directory-alist `(("." . ,pika-backup-directory))
      auto-save-file-name-transforms `((".*" ,pika-auto-save-directory t))
      auto-save-list-file-prefix (expand-file-name ".saves-" pika-auto-save-directory)
      create-lockfiles t
      delete-by-moving-to-trash t
      recentf-save-file (expand-file-name "recentf" pika-var-directory)
      savehist-file (expand-file-name "history" pika-var-directory)
      save-place-file (expand-file-name "places" pika-var-directory)
      bookmark-default-file (expand-file-name "bookmarks" pika-var-directory)
      tramp-persistency-file-name (expand-file-name "tramp" pika-var-directory))

(set-charset-priority 'unicode)
(prefer-coding-system 'utf-8-unix)
(setq-default indent-tabs-mode nil
              tab-width 4
              fill-column 88)

;; Modus Vivendi ships with Emacs and remains readable in GUI and terminal frames.
(mapc #'disable-theme custom-enabled-themes)
(load-theme 'modus-vivendi t)

(column-number-mode 1)
(delete-selection-mode 1)
(electric-pair-mode 1)
(global-auto-revert-mode 1)
(repeat-mode 1)
(save-place-mode 1)
(savehist-mode 1)
(recentf-mode 1)
(show-paren-mode 1)

(add-hook 'prog-mode-hook #'display-line-numbers-mode)

(use-package project
  :ensure nil
  :custom
  (project-list-file (expand-file-name "projects" pika-var-directory))
  (project-switch-commands
   '((project-find-file "Find file")
     (project-find-regexp "Find regexp")
     (project-dired "Dired")
     (project-compile "Compile"))))

(defun pika-ibuffer-use-default-groups ()
  "Group the current Ibuffer listing with the default filter groups."
  (ibuffer-switch-to-saved-filter-groups "default"))

(use-package ibuffer
  :ensure nil
  :hook (ibuffer-mode . pika-ibuffer-use-default-groups)
  :custom
  (ibuffer-show-empty-filter-groups nil)
  ;; The first matching group wins, so specific groups precede broad ones.
  (ibuffer-saved-filter-groups
   '(("default"
      ("Claude" (name . "\\`\\*claude-code"))
      ("Python" (derived-mode . python-base-mode))
      ("CUDA" (derived-mode . cuda-mode))
      ("C/C++" (or (derived-mode . c-mode)
                   (derived-mode . c++-mode)
                   (derived-mode . c-ts-base-mode)))
      ("RTL" (derived-mode . verilog-mode))
      ("Build" (or (derived-mode . makefile-mode)
                   (derived-mode . cmake-mode)
                   (derived-mode . cmake-ts-mode)))
      ("Shell" (or (derived-mode . sh-base-mode)
                   (derived-mode . bash-ts-mode)))
      ("Emacs Lisp" (derived-mode . lisp-data-mode))
      ("Config" (or (derived-mode . conf-mode)
                    (derived-mode . js-json-mode)
                    (derived-mode . json-ts-mode)
                    (derived-mode . yaml-mode)
                    (derived-mode . yaml-ts-mode)
                    (derived-mode . toml-ts-mode)
                    (file-extension . "\\(?:ya?ml\\|toml\\|ini\\|cfg\\)")))
      ("Org" (derived-mode . org-mode))
      ("Markdown" (derived-mode . markdown-mode))
      ("Magit" (or (derived-mode . magit-mode)
                   (derived-mode . forge-topic-mode)))
      ("Dired" (derived-mode . dired-mode))
      ("Terminals" (or (derived-mode . ghostel-mode)
                       (derived-mode . comint-mode)
                       (derived-mode . eshell-mode)))
      ("Compilation" (derived-mode . compilation-mode))
      ("Help" (or (derived-mode . help-mode)
                  (derived-mode . Info-mode)
                  (derived-mode . apropos-mode)
                  (derived-mode . Man-mode)))
      ("Emacs" (name . "\\`\\*"))))))

(provide 'pika-core)
;;; pika-core.el ends here
