;;; pika-voice.el --- Voice control through the voice daemon -*- lexical-binding: t; -*-

;; The voice daemon (~/voice) drives Emacs with `emacsclient --eval' and needs
;; Emacs to report its major mode so mode-specific voice commands activate.
;; `voice-mode' starts the Emacs server and pushes that context.

(defgroup pika-voice nil
  "Voice control integration."
  :group 'environment)

(defcustom pika-voice-lisp-directory (expand-file-name "~/voice/emacs/")
  "Directory containing voice.el from the voice repository."
  :type 'directory)

(use-package voice
  :load-path pika-voice-lisp-directory
  :demand t
  :config
  (voice-mode 1))

(provide 'pika-voice)
;;; pika-voice.el ends here
