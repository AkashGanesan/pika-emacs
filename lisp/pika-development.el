;;; pika-development.el --- Source control and development tools -*- lexical-binding: t; -*-

(use-package auth-source
  :ensure nil
  :custom
  (auth-sources '("~/.authinfo.gpg")))

(use-package transient
  :ensure nil
  :custom
  (transient-history-file
   (expand-file-name "transient-history.el" pika-var-directory))
  (transient-levels-file
   (expand-file-name "transient-levels.el" pika-var-directory))
  (transient-values-file
   (expand-file-name "transient-values.el" pika-var-directory)))

(use-package magit
  :commands (magit-dispatch
             magit-file-dispatch
             magit-log-current
             magit-status)
  :custom
  (magit-display-buffer-function
   #'magit-display-buffer-same-window-except-diff-v1))

(use-package forge
  :after magit
  :commands (forge-add-repository
             forge-dispatch
             forge-pull)
  :custom
  (forge-database-file
   (expand-file-name "forge-database.sqlite" pika-var-directory)))

(defun pika-python-project-root (&optional require)
  "Return the current project root.
When REQUIRE is non-nil, signal a user error outside a project."
  (when-let ((project (project-current require)))
    (project-root project)))

(defun pika-python-configure-environment ()
  "Use the current project's virtual environment for Python tools."
  (when-let* ((root (pika-python-project-root))
              (venv (expand-file-name ".venv" root))
              (venv-bin (expand-file-name "bin" venv))
              (venv-python (expand-file-name "python" venv-bin)))
    (cond
     ((file-executable-p venv-python)
      (setq-local exec-path (cons venv-bin (delete venv-bin (copy-sequence exec-path)))
                  process-environment (copy-sequence process-environment)
                  python-shell-interpreter venv-python
                  python-shell-interpreter-args "-i")
      (let* ((separator (regexp-quote path-separator))
             (path-elements (split-string (or (getenv "PATH") "") separator t)))
        (setenv "PATH"
                (mapconcat #'identity
                           (cons venv-bin (delete venv-bin path-elements))
                           path-separator)))
      (setenv "VIRTUAL_ENV" venv))
     ((file-exists-p (expand-file-name "uv.lock" root))
      (setq-local python-shell-interpreter "uv"
                  python-shell-interpreter-args "run python -i")))))

(defun pika-python-lsp-setup ()
  "Configure Basedpyright and start LSP in the current Python buffer."
  (pika-python-configure-environment)
  (require 'lsp-pyright)
  (lsp-deferred))

(defun pika-python-test ()
  "Run the current project's test suite through uv and compilation mode."
  (interactive)
  (let ((default-directory (pika-python-project-root t)))
    (compile "uv run pytest")))

(defvar-local pika-python-uv-sync-source-buffer nil
  "Python source buffer which started the current uv sync.")

(defun pika-python-uv-sync-finished (_buffer status)
  "Refresh the source buffer environment after uv sync finishes with STATUS."
  (when (and (string-prefix-p "finished" status)
             (buffer-live-p pika-python-uv-sync-source-buffer))
    (with-current-buffer pika-python-uv-sync-source-buffer
      (pika-python-configure-environment)
      (when (bound-and-true-p lsp-mode)
        (lsp-restart-workspace)))
    (message "uv dependencies synchronized")))

(defun pika-python-uv-sync ()
  "Synchronize the current project's dependencies with uv."
  (interactive)
  (let* ((source-buffer (current-buffer))
         (default-directory (pika-python-project-root t))
         (pyproject (expand-file-name "pyproject.toml" default-directory)))
    (unless (file-exists-p pyproject)
      (user-error "No pyproject.toml in %s" default-directory))
    (with-current-buffer (compile "uv sync")
      (setq-local pika-python-uv-sync-source-buffer source-buffer)
      (add-hook 'compilation-finish-functions
                #'pika-python-uv-sync-finished nil t))))

(use-package flycheck
  :hook (python-base-mode . flycheck-mode)
  :config
  (lsp-diagnostics-lsp-checker-if-needed)
  (flycheck-add-next-checker 'lsp '(warning . python-ruff)))

(use-package lsp-mode
  :commands (lsp lsp-deferred lsp-rename)
  :hook (python-base-mode . pika-python-lsp-setup)
  :custom
  (lsp-completion-provider :none)
  (lsp-diagnostics-provider :flycheck)
  (lsp-disabled-clients '(ruff))
  (lsp-enable-file-watchers t)
  (lsp-enable-snippet nil)
  (lsp-keymap-prefix "C-c l")
  :config
  (dolist (directory '(".venv" "build" "datasets" "checkpoints"
                       "sim" "simulation" "waves" "waveforms"))
    (add-to-list
     'lsp-file-watch-ignored-directories
     (format "[/\\\\]%s\\(?:[/\\\\]\\|\\'\\)"
             (regexp-quote directory)))))

(use-package lsp-pyright
  :after lsp-mode
  :custom
  (lsp-pyright-langserver-command "basedpyright")
  (lsp-pyright-type-checking-mode "standard"))

(use-package lsp-ui
  :commands lsp-ui-mode
  :hook (lsp-mode . lsp-ui-mode)
  :custom
  (lsp-ui-doc-enable nil)
  (lsp-ui-sideline-enable nil))

(use-package consult-lsp
  :commands consult-lsp-symbols)

(use-package ruff-format
  :commands (ruff-format-buffer ruff-format-region))

(provide 'pika-development)
;;; pika-development.el ends here
