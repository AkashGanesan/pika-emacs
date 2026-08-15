;;; early-init.el --- Early startup settings -*- lexical-binding: t; -*-

(setq package-enable-at-startup nil
      package-user-dir (expand-file-name "var/elpa/" user-emacs-directory)
      frame-inhibit-implied-resize t
      gc-cons-threshold most-positive-fixnum
      gc-cons-percentage 0.6)

;; Start GUI frames maximized without forcing exclusive fullscreen.
(add-to-list 'initial-frame-alist '(fullscreen . maximized))
(add-to-list 'default-frame-alist '(fullscreen . maximized))

(defun pika-maximize-frame (frame)
  "Maximize graphical FRAME."
  (when (display-graphic-p frame)
    (set-frame-parameter frame 'fullscreen 'maximized)))

(add-hook 'after-make-frame-functions #'pika-maximize-frame)

(menu-bar-mode -1)
(when (fboundp 'scroll-bar-mode)
  (scroll-bar-mode -1))
(when (fboundp 'tool-bar-mode)
  (tool-bar-mode -1))
(when (fboundp 'tooltip-mode)
  (tooltip-mode -1))

(provide 'early-init)
;;; early-init.el ends here
