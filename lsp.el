;;; lsp.el --- LSP configuration (corfu-compatible) -*- lexical-binding: t -*-

;; ---------------------------------------------------------------------------
;; Eglot — JS/TS (built-in Emacs 30, one server per project root)
;; Currently disabled — using lsp-mode for JS/TS instead.
;; To re-enable: uncomment this block and comment out the JS/TS hooks in lsp-mode below.
;; ---------------------------------------------------------------------------
;; (defun my/eglot-ensure-idle ()
;;   "Start eglot after a short idle delay so file open feels instant."
;;   (run-with-idle-timer 0.5 nil #'eglot-ensure))
;;
;; (use-package eglot
;;   :hook ((js-mode            . my/eglot-ensure-idle)
;;          (js-jsx-mode        . my/eglot-ensure-idle)
;;          (js-ts-mode         . my/eglot-ensure-idle)
;;          (typescript-ts-mode . my/eglot-ensure-idle)
;;          (tsx-ts-mode        . my/eglot-ensure-idle))
;;   :custom
;;   (eglot-autoshutdown t)
;;   (eglot-sync-connect nil)
;;   ;; documentHighlight floods large files; inlayHints can be slow in large dirs.
;;   (eglot-ignored-server-capabilities '(:documentHighlightProvider :inlayHintProvider))
;;   :config
;;   (setq completion-category-overrides '((eglot (styles orderless))
;;                                         (eglot-capf (styles orderless)))))

;; ---------------------------------------------------------------------------
;; lsp-mode — JS/TS, Go, Clojure
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
  (lsp-ui-sideline-show-diagnostics t)
  (lsp-ui-sideline-delay            1.0))
