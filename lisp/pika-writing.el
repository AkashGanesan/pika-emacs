;;; pika-writing.el --- Markdown and fiction-writing workflows -*- lexical-binding: t; -*-

(defgroup pika-writing nil
  "Focused prose editing and manuscript workflows."
  :group 'text)

(defcustom pika-writing-manuscript-directory
  (expand-file-name "manuscript/" pika-org-directory)
  "Directory containing the current fiction manuscript."
  :type 'directory
  :group 'pika-writing)

(defun pika-writing-book-file ()
  "Return the current manuscript's master Org file."
  (expand-file-name "book.org" pika-writing-manuscript-directory))

(defun pika-writing-outline-file ()
  "Return the current manuscript's outline Org file."
  (expand-file-name "outline.org" pika-writing-manuscript-directory))

(defun pika-writing-ensure-manuscript-layout ()
  "Create the manuscript directories and capture outline when absent."
  (dolist (directory '("chapters" "exports"))
    (make-directory
     (expand-file-name directory pika-writing-manuscript-directory) t))
  (let ((outline (pika-writing-outline-file)))
    (unless (file-exists-p outline)
      (with-temp-file outline
        (insert "#+title: Manuscript outline\n\n"
                "* Scene ideas\n\n"
                "* Continuity\n")))))

(defun pika-writing-open-book ()
  "Open the current manuscript's master Org file."
  (interactive)
  (pika-writing-ensure-manuscript-layout)
  (find-file (pika-writing-book-file)))

(defun pika-writing-open-outline ()
  "Open the current manuscript's outline and capture file."
  (interactive)
  (pika-writing-ensure-manuscript-layout)
  (find-file (pika-writing-outline-file)))

(defun pika-writing--capture-at-heading (heading)
  "Visit the manuscript outline and move to the end of HEADING."
  (pika-writing-ensure-manuscript-layout)
  (find-file (pika-writing-outline-file))
  (widen)
  (goto-char (point-min))
  (unless (re-search-forward
           (format org-complex-heading-regexp-format
                   (regexp-quote heading))
           nil t)
    (user-error "Missing manuscript outline heading: %s" heading))
  (org-end-of-subtree t t))

(defun pika-writing--capture-scene-location ()
  "Move to the scene-idea capture location."
  (pika-writing--capture-at-heading "Scene ideas"))

(defun pika-writing--capture-continuity-location ()
  "Move to the continuity capture location."
  (pika-writing--capture-at-heading "Continuity"))

(defun pika-writing-capture-scene ()
  "Capture a scene idea linked to the current editing location."
  (interactive)
  (pika-writing-ensure-manuscript-layout)
  (org-capture nil "ws"))

(defun pika-writing-capture-continuity ()
  "Capture a continuity fact linked to the current editing location."
  (interactive)
  (pika-writing-ensure-manuscript-layout)
  (org-capture nil "wc"))

(defun pika-writing-spell-check ()
  "Spell-check the current prose buffer with Aspell."
  (interactive)
  (unless (executable-find ispell-program-name)
    (user-error "%s is not available in exec-path" ispell-program-name))
  (ispell-buffer))

(defun pika-writing-export-manuscript ()
  "Export the master Org manuscript and its includes to exports/book.html."
  (interactive)
  (pika-writing-ensure-manuscript-layout)
  (let* ((book (pika-writing-book-file))
         (output (expand-file-name "exports/book.html"
                                   pika-writing-manuscript-directory)))
    (unless (file-exists-p book)
      (user-error "Manuscript master file does not exist: %s" book))
    (with-current-buffer (find-file-noselect book)
      (require 'ox-html)
      (org-export-to-file 'html output))
    (message "Exported manuscript to %s" output)
    output))

(define-minor-mode pika-writing-focus-mode
  "Toggle a centered, variable-pitch presentation for long-form prose."
  :lighter " Focus"
  (if pika-writing-focus-mode
      (progn
        (olivetti-mode 1)
        (variable-pitch-mode 1))
    (variable-pitch-mode -1)
    (olivetti-mode -1)))

(use-package markdown-mode
  :mode (("\\.markdown\\'" . markdown-mode)
         ("\\.md\\'" . markdown-mode)
         ("README\\.md\\'" . gfm-mode))
  :custom
  (markdown-fontify-code-blocks-natively t)
  (markdown-header-scaling t))

(use-package ispell
  :ensure nil
  :custom
  (ispell-program-name "aspell"))

(use-package flyspell
  :ensure nil
  :hook ((org-mode . flyspell-mode)
         (markdown-mode . flyspell-mode)))

(use-package olivetti
  :commands olivetti-mode
  :custom
  (olivetti-body-width 88))

(with-eval-after-load 'org
  (dolist (template
           `(("w" "Writing")
             ("ws" "Scene idea" entry
              (function pika-writing--capture-scene-location)
              "* %^{Scene title}\n:PROPERTIES:\n:CREATED: %U\n:END:\n- Source :: %a\n- Characters :: %?\n- Setting ::\n- Purpose ::\n- Conflict ::\n")
             ("wc" "Continuity" entry
              (function pika-writing--capture-continuity-location)
              "* %^{Continuity issue}\n:PROPERTIES:\n:CREATED: %U\n:END:\n- Source :: %a\n- Characters :: %?\n- Setting ::\n- Established fact ::\n- Follow-up ::\n")))
    (add-to-list 'org-capture-templates template t)))

(with-eval-after-load 'org-roam
  (dolist (template
           '(("k" "Character" plain
              "* Role in the story\n\n%?\n\n* Relationships\n\n* Continuity\n"
              :target (file+head "fiction/%<%Y%m%d%H%M%S>-${slug}.org"
                                 "#+title: ${title}\n#+filetags: :fiction:character:\n#+created: %U\n\n")
              :unnarrowed t)
             ("s" "Setting" plain
              "* Description\n\n%?\n\n* Story function\n\n* Continuity\n"
              :target (file+head "fiction/%<%Y%m%d%H%M%S>-${slug}.org"
                                 "#+title: ${title}\n#+filetags: :fiction:setting:\n#+created: %U\n\n")
              :unnarrowed t)))
    (add-to-list 'org-roam-capture-templates template t)))

(provide 'pika-writing)
;;; pika-writing.el ends here
