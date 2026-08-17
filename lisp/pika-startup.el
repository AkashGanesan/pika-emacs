;;; pika-startup.el --- Futuristic city startup dashboard -*- lexical-binding: t; -*-

(require 'button)
(require 'project)
(require 'seq)

(defgroup pika-startup nil
  "Startup dashboard for recent work."
  :group 'environment)

(defcustom pika-startup-project-limit 6
  "Maximum number of recent projects shown on the dashboard."
  :type 'integer
  :group 'pika-startup)

(defcustom pika-startup-file-limit 8
  "Maximum number of recent files shown on the dashboard."
  :type 'integer
  :group 'pika-startup)

(defcustom pika-startup-logo-file
  (expand-file-name "assets/pika-city.svg" user-emacs-directory)
  "Futuristic city logo displayed by the startup dashboard."
  :type 'file
  :group 'pika-startup)

(defface pika-startup-title
  '((t :inherit variable-pitch :height 1.7 :weight bold))
  "Face for the dashboard title."
  :group 'pika-startup)

(defface pika-startup-subtitle
  '((t :inherit shadow :height 1.05))
  "Face for the dashboard subtitle."
  :group 'pika-startup)

(defface pika-startup-section
  '((t :inherit font-lock-keyword-face :height 1.2 :weight bold))
  "Face for dashboard section headings."
  :group 'pika-startup)

(defface pika-startup-path
  '((t :inherit shadow))
  "Face for secondary dashboard paths."
  :group 'pika-startup)

(defvar-keymap pika-startup-mode-map
  :doc "Keymap for the Pika startup dashboard."
  "DEL" #'scroll-down-command
  "RET" #'push-button
  "SPC" #'scroll-up-command
  "TAB" #'pika-startup-next-item
  "<backtab>" #'pika-startup-previous-item
  "<down>" #'pika-startup-next-item
  "<next>" #'scroll-up-command
  "<prior>" #'scroll-down-command
  "<return>" #'push-button
  "<tab>" #'pika-startup-next-item
  "<up>" #'pika-startup-previous-item
  "f" #'find-file
  "g" #'pika-startup-refresh
  "j" #'pika-startup-next-item
  "k" #'pika-startup-previous-item
  "p" #'project-switch-project
  "q" #'bury-buffer)

(define-derived-mode pika-startup-mode special-mode "Pika Startup"
  "Major mode for the Pika Emacs startup dashboard."
  (setq-local cursor-type 'box
              truncate-lines t)
  (buffer-face-set 'variable-pitch)
  (hl-line-mode 1))

(defun pika-startup-next-item ()
  "Move to the next dashboard item, wrapping at the end."
  (interactive)
  (forward-button 1 t t t))

(defun pika-startup-previous-item ()
  "Move to the previous dashboard item, wrapping at the beginning."
  (interactive)
  (forward-button -1 t t t))

(defun pika-startup--insert-block-indent ()
  "Move display to the left edge of the centered dashboard column."
  (insert (propertize " "
                      'display '(space :align-to (- center 48)))))

(defun pika-startup--centered-line (text &optional face)
  "Insert TEXT centered in the dashboard column using FACE."
  (pika-startup--insert-block-indent)
  (insert (make-string (max 0 (/ (- 96 (string-width text)) 2)) ?\s))
  (insert (if face (propertize text 'face face) text))
  (insert "\n"))

(defun pika-startup--insert-logo ()
  "Insert the configured city logo when images are available."
  (if (and (display-images-p)
           (image-type-available-p 'svg)
           (file-readable-p pika-startup-logo-file))
      (let ((image (create-image pika-startup-logo-file 'svg nil :width 430)))
        (pika-startup--insert-block-indent)
        (insert (make-string 21 ?\s))
        (insert-image image "Pika Emacs city")
        (insert "\n"))
    (pika-startup--centered-line "[ PIKA // ORBITAL CONSOLE ]"
                                 'pika-startup-title)))

(defun pika-startup--displayable-file-p (file)
  "Return non-nil when FILE is useful on the recent-files dashboard."
  (let* ((expanded (expand-file-name file))
         (basename (file-name-nondirectory expanded)))
    (and (file-regular-p expanded)
         (not (file-in-directory-p expanded pika-var-directory))
         (not (string-match-p
               "\\`\\(?:session\\.\\|\\.lsp-session\\|\\.#\\)" basename))
         (not (string-match-p
               "/\\(?:site-packages\\|node_modules\\)/" expanded))
         (not (and (boundp 'package-user-dir)
                   package-user-dir
                   (file-in-directory-p expanded package-user-dir))))))

(defun pika-startup--recent-files ()
  "Return the most recent useful files for the dashboard."
  (seq-take
   (seq-uniq
    (seq-filter #'pika-startup--displayable-file-p recentf-list)
    #'file-equal-p)
   pika-startup-file-limit))

(defun pika-startup--recent-projects ()
  "Return existing known projects for the dashboard."
  (seq-take
   (seq-filter #'file-directory-p (project-known-project-roots))
   pika-startup-project-limit))

(defun pika-startup--open-file-button (button)
  "Visit the file stored on BUTTON."
  (find-file (button-get button 'pika-path)))

(defun pika-startup--open-project-button (button)
  "Open the project directory stored on BUTTON."
  (dired (button-get button 'pika-path)))

(defun pika-startup--insert-item (label path action)
  "Insert a dashboard item for LABEL and PATH using ACTION."
  (pika-startup--insert-block-indent)
  (insert-text-button label
                      'action action
                      'follow-link t
                      'help-echo path
                      'pika-path path)
  (insert "  ")
  (insert (propertize
           (truncate-string-to-width
            (abbreviate-file-name path) 68 nil nil "…")
           'face 'pika-startup-path))
  (insert "\n"))

(defun pika-startup--insert-projects ()
  "Insert recent project buttons."
  (pika-startup--insert-block-indent)
  (insert (propertize "Recent projects\n" 'face 'pika-startup-section))
  (let ((projects (pika-startup--recent-projects)))
    (if projects
        (dolist (path projects)
          (pika-startup--insert-item
           (file-name-nondirectory (directory-file-name path))
           path #'pika-startup--open-project-button))
      (pika-startup--insert-block-indent)
      (insert (propertize "No known projects yet.\n"
                          'face 'pika-startup-path)))))

(defun pika-startup--insert-files ()
  "Insert recent file buttons."
  (pika-startup--insert-block-indent)
  (insert (propertize "Recent files\n" 'face 'pika-startup-section))
  (let ((files (pika-startup--recent-files)))
    (if files
        (dolist (path files)
          (pika-startup--insert-item
           (file-name-nondirectory path)
           path #'pika-startup--open-file-button))
      (pika-startup--insert-block-indent)
      (insert (propertize "No recent files yet.\n"
                          'face 'pika-startup-path)))))

(defun pika-startup-refresh ()
  "Refresh the Pika startup dashboard."
  (interactive)
  (let ((inhibit-read-only t))
    (erase-buffer)
    (pika-startup--insert-logo)
    (pika-startup--centered-line "PIKA EMACS" 'pika-startup-title)
    (pika-startup--centered-line
     "Research, hardware, knowledge, and fiction in one orbit"
     'pika-startup-subtitle)
    (insert "\n")
    (pika-startup--insert-projects)
    (insert "\n")
    (pika-startup--insert-files)
    (insert "\n")
    (pika-startup--centered-line
     "[up/down or j/k] select   [RET] open   [SPC/DEL] scroll"
     'pika-startup-subtitle)
    (pika-startup--centered-line
     "[p] projects   [f] find file   [g] refresh   [q] close"
     'pika-startup-subtitle)
    (goto-char (point-min))
    (forward-button 1 t nil t)))

(defun pika-startup-buffer ()
  "Return a refreshed Pika startup dashboard buffer."
  (let ((buffer (get-buffer-create "*pika-emacs*")))
    (with-current-buffer buffer
      (unless (derived-mode-p 'pika-startup-mode)
        (pika-startup-mode))
      (pika-startup-refresh))
    buffer))

(setq initial-buffer-choice #'pika-startup-buffer)

(provide 'pika-startup)
;;; pika-startup.el ends here
