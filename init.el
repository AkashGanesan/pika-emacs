;;; init.el --- Personal Emacs configuration -*- lexical-binding: t; -*-

(require 'package)

(setq package-archives
      '(("gnu"    . "https://elpa.gnu.org/packages/")
        ("nongnu" . "https://elpa.nongnu.org/nongnu/")
        ("melpa"  . "https://melpa.org/packages/"))
      package-archive-priorities
      '(("gnu" . 30)
        ("nongnu" . 20)
        ("melpa" . 10)))

(package-initialize)

(require 'use-package)
(setq use-package-always-ensure t
      use-package-expand-minimally t)

(defconst pika-var-directory
  (expand-file-name "var/" user-emacs-directory))
(make-directory pika-var-directory t)

(setq custom-file (expand-file-name "custom.el" pika-var-directory))
(load custom-file 'noerror 'nomessage)

(add-to-list 'load-path (expand-file-name "lisp/" user-emacs-directory))

(require 'pika-core)
(require 'pika-completion)
(require 'pika-development)
(require 'pika-hardware)
(require 'pika-org)
(require 'pika-writing)
(require 'pika-bindings)

(defun pika-restore-startup-settings ()
  "Restore garbage collection settings after startup."
  (setq gc-cons-threshold (* 32 1024 1024)
        gc-cons-percentage 0.1))

(add-hook 'emacs-startup-hook #'pika-restore-startup-settings)

(provide 'init)
;;; init.el ends here
