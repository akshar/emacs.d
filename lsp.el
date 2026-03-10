;;; lsp.el --- LSP configuration (corfu-compatible) -*- lexical-binding: t -*-

;; ---------------------------------------------------------------------------
;; Eglot — JS/TS (built-in Emacs 30, one server per monorepo root)
;; To switch to lsp-mode: comment this block and uncomment the JS/TS hooks below.
;; ---------------------------------------------------------------------------
(use-package eglot
  :hook ((js-mode            . eglot-ensure)
         (js-jsx-mode        . eglot-ensure)
         (js-ts-mode         . eglot-ensure)
         (typescript-ts-mode . eglot-ensure)
         (tsx-ts-mode        . eglot-ensure))
  :custom
  (eglot-autoshutdown t)
  (eglot-ignored-server-capabilities '(:documentHighlightProvider))
  :config
  (setq completion-category-overrides '((eglot (styles orderless))
                                        (eglot-capf (styles orderless)))))

;; ---------------------------------------------------------------------------
;; lsp-mode — Go, Clojure (JS/TS via eglot above)
;; ---------------------------------------------------------------------------
(defun my/lsp-mode-setup-completion ()
  "Configure orderless for lsp-mode completions."
  (setf (alist-get 'styles (alist-get 'lsp-capf completion-category-defaults))
        '(orderless)))

(use-package lsp-mode
  :ensure t
  :commands (lsp lsp-deferred)
  :custom
  (lsp-completion-provider :none)
  (lsp-idle-delay 0.5)
  (lsp-log-io nil)
  (lsp-enable-file-watchers nil)
  (lsp-file-watch-threshold 500)
  (lsp-typescript-surveys-enabled nil)
  (lsp-javascript-suggest-auto-imports t)
  :hook ((lsp-mode            . lsp-enable-which-key-integration)
         (lsp-completion-mode . my/lsp-mode-setup-completion)
         ;; JS/TS via lsp-mode — commented out, using eglot instead
         ;; (js-mode             . lsp-deferred)
         ;; (js-jsx-mode         . lsp-deferred)
         ;; (typescript-ts-mode  . lsp-deferred)
         ;; (tsx-ts-mode         . lsp-deferred)
         ;; (js-ts-mode          . lsp-deferred)
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
  (lsp-ui-sideline-show-diagnostics t)
  (lsp-ui-sideline-delay            1.0))
