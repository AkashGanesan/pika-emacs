;;; pika-hardware.el --- C++, CUDA, RTL, and simulation workflows -*- lexical-binding: t; -*-

(defvar pika-hardware-test-history nil
  "History of hardware test names.")

(defvar pika-hardware-seed-history nil
  "History of hardware simulation seeds.")

(defun pika-hardware-project-root ()
  "Return the current project root, or signal a user error."
  (project-root (project-current t)))

(defun pika-hardware-compile (command)
  "Run project-local build COMMAND through compilation mode."
  (let ((default-directory (pika-hardware-project-root)))
    (compile command)))

(defun pika-hardware-lint ()
  "Run the current hardware project's lint target."
  (interactive)
  (pika-hardware-compile "make lint"))

(defun pika-hardware-build ()
  "Run the current hardware project's compile target."
  (interactive)
  (pika-hardware-compile "make compile"))

(defun pika-hardware-test (test seed)
  "Run TEST with SEED through the current project's test target."
  (interactive
   (list (read-string "Test: " nil 'pika-hardware-test-history "smoke")
         (read-string "Seed: " nil 'pika-hardware-seed-history "1")))
  (pika-hardware-compile
   (format "make test TEST=%s SEED=%s"
           (shell-quote-argument test)
           (shell-quote-argument seed))))

(defun pika-hardware-regress ()
  "Run the current hardware project's regression target."
  (interactive)
  (pika-hardware-compile "make regress"))

(defun pika-hardware-waves (test)
  "Open waveforms for TEST through the project-local waves target."
  (interactive
   (list (read-string "Test: " nil 'pika-hardware-test-history "smoke")))
  (pika-hardware-compile
   (format "make waves TEST=%s" (shell-quote-argument test))))

(defun pika-clangd-setup ()
  "Start Clangd for C, C++, or CUDA using project compilation data."
  (require 'lsp-clangd)
  (when (derived-mode-p 'cuda-mode)
    (add-to-list 'lsp-language-id-configuration '(cuda-mode . "cuda")))
  (lsp-deferred))

(defun pika-verilog-lsp-setup ()
  "Start Verible for the current Verilog or SystemVerilog buffer."
  (require 'lsp-verilog)
  (setq-local lsp-enabled-clients '(lsp-verilog-verible))
  (lsp-deferred))

(defun pika-cuda-gdb (executable)
  "Debug CUDA EXECUTABLE with cuda-gdb using Emacs's GDB interface."
  (interactive
   (list (read-file-name "CUDA executable: "
                         (pika-hardware-project-root) nil t)))
  (unless (executable-find "cuda-gdb")
    (user-error "cuda-gdb is not available in exec-path"))
  (gdb (format "cuda-gdb -i=mi %s" (shell-quote-argument executable))))

(with-eval-after-load 'lsp-clangd
  (setq lsp-clients-clangd-args
        '("--background-index"
          "--clang-tidy"
          "--completion-style=detailed"
          "--header-insertion=never")))

(use-package gdb-mi
  :ensure nil
  :custom
  (gdb-debuginfod-enable-setting nil))

(use-package cc-mode
  :ensure nil
  :hook ((c-mode . pika-clangd-setup)
         (c++-mode . pika-clangd-setup)
         (c-ts-mode . pika-clangd-setup)
         (c++-ts-mode . pika-clangd-setup)))

(use-package cuda-mode
  :mode (("\\.cu\\'" . cuda-mode)
         ("\\.cuh\\'" . cuda-mode))
  :hook (cuda-mode . pika-clangd-setup))

(use-package verilog-mode
  :ensure nil
  :mode (("\\.v\\'" . verilog-mode)
         ("\\.sv\\'" . verilog-mode)
         ("\\.svh\\'" . verilog-mode))
  :hook (verilog-mode . pika-verilog-lsp-setup)
  :custom
  (verilog-auto-newline nil)
  (verilog-auto-endcomments nil)
  (verilog-indent-level 2)
  (verilog-indent-level-module 2)
  (verilog-indent-level-declaration 2)
  (verilog-indent-level-behavioral 2))

(use-package reformatter
  :config
  (reformatter-define pika-verible-format
    :program "verible-verilog-format"
    :args (list "--stdin_name" (or buffer-file-name "<stdin>") "-")))

(provide 'pika-hardware)
;;; pika-hardware.el ends here
