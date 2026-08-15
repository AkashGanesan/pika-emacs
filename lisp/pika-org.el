;;; pika-org.el --- Org knowledge, citation, and code workflows -*- lexical-binding: t; -*-

(defconst pika-org-directory (expand-file-name "~/org/"))
(defconst pika-org-agenda-directory
  (expand-file-name "agenda/" pika-org-directory))
(defconst pika-org-roam-directory
  (expand-file-name "roam/" pika-org-directory))
(defconst pika-org-bibliography-directory
  (expand-file-name "bibliography/" pika-org-directory))
(defconst pika-org-inbox-file
  (expand-file-name "inbox.org" pika-org-agenda-directory))
(defconst pika-org-projects-file
  (expand-file-name "projects.org" pika-org-agenda-directory))
(defconst pika-org-someday-file
  (expand-file-name "someday.org" pika-org-agenda-directory))
(defconst pika-org-bibliography-file
  (expand-file-name "references.bib" pika-org-bibliography-directory))

(dolist (directory
         (list pika-org-agenda-directory
               pika-org-roam-directory
               pika-org-bibliography-directory
               (expand-file-name "files/" pika-org-bibliography-directory)
               (expand-file-name "concepts/" pika-org-roam-directory)
               (expand-file-name "experiments/" pika-org-roam-directory)
               (expand-file-name "fiction/" pika-org-roam-directory)
               (expand-file-name "hardware/" pika-org-roam-directory)
               (expand-file-name "projects/" pika-org-roam-directory)
               (expand-file-name "references/" pika-org-roam-directory)
               (expand-file-name "rl/" pika-org-roam-directory)))
  (make-directory directory t))

(use-package org
  :ensure nil
  :hook ((org-mode . visual-line-mode)
         (org-mode . org-indent-mode))
  :custom
  (org-directory pika-org-directory)
  (org-agenda-files (list pika-org-agenda-directory))
  (org-archive-location "%s_archive::")
  (org-capture-templates
   `(("t" "Task" entry (file ,pika-org-inbox-file)
      "* TODO %?\n:PROPERTIES:\n:CREATED: %U\n:END:\n%a\n")
     ("n" "Fleeting note" entry (file ,pika-org-inbox-file)
      "* %?\n:PROPERTIES:\n:CREATED: %U\n:END:\n%a\n")
     ("p" "Project" entry (file ,pika-org-projects-file)
      "* TODO %^{Project}\n:PROPERTIES:\n:CREATED: %U\n:END:\n%?\n")
     ("s" "Someday" entry (file ,pika-org-someday-file)
      "* SOMEDAY %?\n:PROPERTIES:\n:CREATED: %U\n:END:\n%a\n")))
  (org-cite-global-bibliography (list pika-org-bibliography-file))
  (org-cite-insert-processor 'citar)
  (org-cite-follow-processor 'citar)
  (org-cite-activate-processor 'citar)
  (org-confirm-babel-evaluate t)
  (org-default-notes-file pika-org-inbox-file)
  (org-id-locations-file
   (expand-file-name "org-id-locations" pika-var-directory))
  (org-persist-directory
   (expand-file-name "org-persist/" pika-var-directory))
  (org-edit-src-content-indentation 0)
  (org-log-done 'time)
  (org-log-into-drawer t)
  (org-src-fontify-natively t)
  (org-src-preserve-indentation t)
  (org-src-tab-acts-natively t)
  (org-src-window-setup 'current-window)
  (org-startup-folded 'content)
  (org-startup-indented t)
  (org-todo-keywords
   '((sequence "TODO(t)" "NEXT(n)" "WAIT(w@/!)" "SOMEDAY(s)"
               "|" "DONE(d!)" "CANCELLED(c@)")))
  (org-use-speed-commands t)
  :config
  (require 'org-tempo)
  (require 'ob-tangle)
  (org-babel-do-load-languages
   'org-babel-load-languages
   '((C . t)
     (emacs-lisp . t)
     (python . t)
     (shell . t)))
  (setq org-babel-python-command "python3")
  (dolist (template
           '(("el" . "src emacs-lisp")
             ("py" . "src python")
             ("sh" . "src shell")
             ("cc" . "src C")
             ("cpp" . "src C++")
             ("sv" . "src systemverilog")
             ("v" . "src verilog")))
    (add-to-list 'org-structure-template-alist template))
  (dolist (mapping
           '(("systemverilog" . verilog)
             ("verilog" . verilog)))
    (add-to-list 'org-src-lang-modes mapping))
  (dolist (extension
           '(("systemverilog" . "sv")
             ("verilog" . "v")))
    (add-to-list 'org-babel-tangle-lang-exts extension)))

(use-package org-roam
  :custom
  (org-roam-directory (file-truename pika-org-roam-directory))
  (org-roam-db-location
   (expand-file-name "org-roam.sqlite" pika-var-directory))
  (org-roam-completion-everywhere t)
  (org-roam-node-display-template
   (concat "${title:*} " (propertize "${tags:24}" 'face 'org-tag)))
  (org-roam-capture-templates
   '(("c" "Concept" plain "%?"
      :target (file+head "concepts/%<%Y%m%d%H%M%S>-${slug}.org"
                         "#+title: ${title}\n#+filetags: :concept:\n#+created: %U\n\n")
      :unnarrowed t)
     ("l" "Literature note" plain
      "* Citation\n\n%?\n\n* Claims\n\n* Connections\n"
      :target (file+head "references/%<%Y%m%d%H%M%S>-${slug}.org"
                         "#+title: ${title}\n#+filetags: :literature:\n#+created: %U\n\n")
      :unnarrowed t)
     ("h" "Hardware note" plain "%?"
      :target (file+head "hardware/%<%Y%m%d%H%M%S>-${slug}.org"
                         "#+title: ${title}\n#+filetags: :hardware:\n#+created: %U\n\n")
      :unnarrowed t)
     ("r" "RL note" plain "%?"
      :target (file+head "rl/%<%Y%m%d%H%M%S>-${slug}.org"
                         "#+title: ${title}\n#+filetags: :rl:\n#+created: %U\n\n")
      :unnarrowed t)
     ("f" "Fiction note" plain "%?"
      :target (file+head "fiction/%<%Y%m%d%H%M%S>-${slug}.org"
                         "#+title: ${title}\n#+filetags: :fiction:\n#+created: %U\n\n")
      :unnarrowed t)
     ("p" "Project note" plain
      "* Goal\n\n%?\n\n* Status\n\n* Next actions\n"
      :target (file+head "projects/%<%Y%m%d%H%M%S>-${slug}.org"
                         "#+title: ${title}\n#+filetags: :project:\n#+created: %U\n\n")
      :unnarrowed t)
     ("e" "Experiment note" plain
      "* Hypothesis\n\n%?\n\n* Setup\n\n- Commit ::\n- Command ::\n- Seed ::\n\n* Result\n\n* Interpretation\n"
      :target (file+head "experiments/%<%Y%m%d%H%M%S>-${slug}.org"
                         "#+title: ${title}\n#+filetags: :experiment:\n#+created: %U\n\n")
      :unnarrowed t)))
  :config
  (org-roam-db-autosync-mode 1))

(use-package citar
  :custom
  (citar-bibliography (list pika-org-bibliography-file))
  (citar-library-paths
   (list (expand-file-name "files/" pika-org-bibliography-directory)))
  (citar-notes-paths (list pika-org-roam-directory)))

(provide 'pika-org)
;;; pika-org.el ends here
