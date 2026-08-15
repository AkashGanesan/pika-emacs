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

(provide 'pika-development)
;;; pika-development.el ends here
