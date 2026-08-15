;;; pika-writing.el --- Markdown and prose editing support -*- lexical-binding: t; -*-

(use-package markdown-mode
  :mode (("\\.markdown\\'" . markdown-mode)
         ("\\.md\\'" . markdown-mode)
         ("README\\.md\\'" . gfm-mode))
  :custom
  (markdown-fontify-code-blocks-natively t)
  (markdown-header-scaling t))

(provide 'pika-writing)
;;; pika-writing.el ends here
