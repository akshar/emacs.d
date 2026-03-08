;;; lang/python.el --- Python via lsp-pyright -*- lexical-binding: t -*-

(setq python-shell-interpreter "python3")

;; lsp-pyright replaces elpy.
;; Prerequisites (one-time): npm install -g pyright
(use-package lsp-pyright
  :ensure t
  :hook (python-mode . (lambda ()
                         (require 'lsp-pyright)
                         (lsp-deferred))))

;; virtualenvwrapper: activate venvs with M-x venv-workon.
;; lsp-pyright auto-detects the active venv interpreter.
(use-package virtualenvwrapper
  :ensure t
  :config
  (venv-initialize-interactive-shells)
  (venv-initialize-eshell)
  ;; Restart lsp after switching venv so pyright resolves the new interpreter.
  (add-hook 'venv-postactivate-hook
            (lambda ()
              (when (bound-and-true-p lsp-mode)
                (lsp-restart-workspace)))))
