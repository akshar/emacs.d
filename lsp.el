;;; lsp.el --- LSP configuration (corfu-compatible) -*- lexical-binding: t -*-

(defun my/lsp-mode-setup-completion ()
  "Configure orderless for lsp-mode completions."
  (setf (alist-get 'styles (alist-get 'lsp-capf completion-category-defaults))
        '(orderless)))

(use-package lsp-mode
  :ensure t
  :commands (lsp lsp-deferred)
  :custom
  ;; Disable company-mode integration so lsp feeds candidates via capf,
  ;; which corfu reads directly.
  (lsp-completion-provider :none)
  (lsp-idle-delay 0.5)
  (lsp-log-io nil)
  (lsp-typescript-surveys-enabled nil)
  (lsp-javascript-suggest-auto-imports t)
  :hook ((lsp-mode            . lsp-enable-which-key-integration)
         (lsp-completion-mode . my/lsp-mode-setup-completion)
         (js-mode             . lsp-deferred)
         (js-jsx-mode         . lsp-deferred)
         (typescript-ts-mode  . lsp-deferred)
         (tsx-ts-mode         . lsp-deferred)
         (js-ts-mode          . lsp-deferred)
         (go-mode             . lsp)
         (clojure-mode        . lsp-deferred)
         (clojurescript-mode  . lsp-deferred)
         (clojurec-mode       . lsp-deferred)))

(use-package lsp-ui
  :ensure t
  :commands lsp-ui-mode
  :custom
  (lsp-ui-doc-enable                t)
  (lsp-ui-doc-show-with-cursor      nil)
  (lsp-ui-sideline-enable           t)
  (lsp-ui-sideline-show-diagnostics t))
