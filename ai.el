;;; ai.el --- AI tools

;; ---------------------------------------------------------------------------
;; gptel — multi-provider AI chat (Claude, GPT-4, Gemini, Ollama)
;; Prerequisite: add API key to ~/.authinfo:
;;   machine api.anthropic.com password <api-key>
;; ---------------------------------------------------------------------------
(use-package gptel
  :ensure t
  :custom
  (gptel-model 'claude-sonnet-4-6)
  :config
  (gptel-make-anthropic "Claude"
    :stream t
    :key (lambda () (auth-source-pick-first-password :host "api.anthropic.com"))))
