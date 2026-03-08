;;; lang/GO.el --- Go development

;; go-ts-mode is built-in since Emacs 29 — no package needed.
;; Prerequisite: go install golang.org/x/tools/gopls@latest

(use-package go-ts-mode
  :ensure nil
  :mode "\\.go\\'"
  :hook ((go-ts-mode . lsp-deferred)
         (go-ts-mode . (lambda ()
                         (add-hook 'before-save-hook #'lsp-format-buffer t t)
                         (add-hook 'before-save-hook #'lsp-organize-imports t t))))
  :custom
  (go-ts-mode-indent-offset 4))

;; go-tag — add/edit/remove struct field tags (json, db, yaml, etc.)
;; C-c t a / C-c t r
(use-package go-tag
  :ensure t
  :bind (:map go-ts-mode-map
              ("C-c t a" . go-tag-add)
              ("C-c t r" . go-tag-remove)))
