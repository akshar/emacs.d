(use-package flycheck-clj-kondo
  :ensure t)

(use-package clojure-mode
  :ensure t
  :config
  (require 'flycheck-clj-kondo)
  ;; aggressive-indent misidentifies top-level form boundaries in Clojure,
  ;; causing it to pull the next defn onto the current line.
  (add-to-list 'aggressive-indent-excluded-modes 'clojure-mode)
  (add-to-list 'aggressive-indent-excluded-modes 'clojurescript-mode)
  (add-to-list 'aggressive-indent-excluded-modes 'clojurec-mode))

(use-package paredit
  :ensure t
  :init
  (add-hook 'clojure-mode-hook 'enable-paredit-mode)
  (add-hook 'cider-repl-mode-hook 'enable-paredit-mode)
  (add-hook 'emacs-lisp-mode-hook 'enable-paredit-mode))

(use-package cider
:ensure t
:defer 3
:init (setq cider-repl-pop-to-buffer-on-connect t
             cider-save-file-on-load nil
cider-mode-line nil
cider-prompt-for-symbol nil
cider-show-error-buffer t
cider-auto-select-error-buffer t
cider-repl-history-file "~/.emacs.d/cider-history"
cider-repl-wrap-history t
cider-repl-history-size 100
cider-repl-use-clojure-font-lock t
cider-docview-fill-column 70
cider-stacktrace-fill-column 76
nrepl-hide-special-buffers t
nrepl-popup-stacktraces nil
nrepl-log-messages nil
cider-repl-use-pretty-printing t
cider-repl-display-help-banner nil
cider-repl-result-prefix ";; => ")
:config
(define-key cider-mode-map (kbd "M-c")
'cider-pprint-eval-defun-to-comment)
(add-hook 'cider-mode-hook #'eldoc-mode)
(add-hook 'cider-repl-mode-hook #'eldoc-mode)
;; corfu (global-corfu-mode) handles completion — no company-mode needed
(define-key cider-repl-mode-map (kbd "s-k")
  'cider-repl-clear-buffer))

(use-package clj-refactor
  :ensure t
  :hook (clojure-mode . (lambda ()
          (clj-refactor-mode 1)
          (cljr-add-keybindings-with-prefix "C-c C-m"))))

(use-package kibit-helper
:ensure t)
