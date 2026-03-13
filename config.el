;;; config.el --- Main configuration -*- lexical-binding: t -*-

;; ---------------------------------------------------------------------------
;; Shell PATH (macOS GUI Emacs doesn't inherit shell PATH)
;; ---------------------------------------------------------------------------
(use-package exec-path-from-shell
  :ensure t
  :if (memq window-system '(mac ns))
  :config (exec-path-from-shell-initialize))

;; ---------------------------------------------------------------------------
;; Interface basics
;; ---------------------------------------------------------------------------
(setq inhibit-startup-message t)
(setq make-backup-files nil)
(setq auto-save-file-name-transforms
      `((".*" ,(expand-file-name "auto-save/" user-emacs-directory) t)))
(setq frame-title-format
      '((:eval (if (buffer-file-name)
                   (abbreviate-file-name (buffer-file-name))
                 "%b"))))

(tool-bar-mode -1)
(scroll-bar-mode -1)
(fset 'yes-or-no-p 'y-or-n-p)

;; ---------------------------------------------------------------------------
;; Redisplay / font-lock performance
;; ---------------------------------------------------------------------------
;; Defer fontification — buffer appears immediately, highlighting fills in after.
(setq jit-lock-defer-time 0.1)

;; Don't re-fontify while actively typing.
(setq redisplay-skip-fontification-on-input t)

;; Stealth fontification: process un-highlighted regions in small chunks during
;; idle time instead of one large blocking burst when the defer timer fires.
(setq jit-lock-stealth-time 2
      jit-lock-stealth-nice 0.2
      jit-lock-stealth-verbose nil)

;; Level 4 = maximum highlighting (operators, type params, decorators, everything).
;; Large files (>100KB) have font-lock disabled entirely by so-long-mode anyway.
(setq treesit-font-lock-level 4)

;; so-long-mode: built-in, disables font-lock/line-numbers/etc for large files.
;; Default only triggers on long-line files. Extend it to also trigger on large
;; files by size — TypeScript files in large dirs have normal line lengths but can
;; be huge, which is why so-long never fired before.
(global-so-long-mode 1)
(setq so-long-threshold 500          ; characters per line (keep default-ish)
      so-long-max-lines 5)           ; lines to check for long-line detection
(setq so-long-predicate
      (lambda ()
        ;; Trigger on long lines (original behavior) OR large file (new).
        (or (so-long-detected-long-line-p)
            (> (buffer-size) (* 100 1024)))))  ; 100 KB

;; Add our custom modes to so-long's disable list (font-lock-mode is already there).
(dolist (mode '(indent-bars-mode git-gutter-mode beacon-mode))
  (add-to-list 'so-long-minor-modes mode))

;; ---------------------------------------------------------------------------

(global-display-line-numbers-mode)
(defalias 'list-buffers 'ibuffer)
(windmove-default-keybindings)
(global-hl-line-mode t)
(global-auto-revert-mode 1)
;; Use OS file-system notifications (kqueue on macOS) instead of polling.
;; Without this, Emacs polls every `auto-revert-interval` seconds per buffer.
(setq auto-revert-use-notify t
      auto-revert-avoid-polling t)

;; ---------------------------------------------------------------------------
;; Custom functions + global keybindings
;; ---------------------------------------------------------------------------
(defmacro move-back-horizontal-after (&rest code)
  `(let ((horizontal-position (current-column)))
     (progn
       ,@code
       (move-to-column horizontal-position))))

(defun comment-or-uncomment-line-or-region ()
  (interactive)
  (if (region-active-p)
      (comment-or-uncomment-region (region-beginning) (region-end))
    (move-back-horizontal-after
     (comment-or-uncomment-region (line-beginning-position) (line-end-position))
     (forward-line 1))))

(global-set-key (kbd "M-;")         'comment-or-uncomment-line-or-region)
(global-set-key (kbd "<f5>")        'revert-buffer)
(global-set-key (kbd "M-s-<right>") 'switch-to-next-buffer)
(global-set-key (kbd "M-s-<left>")  'switch-to-prev-buffer)
(global-set-key (kbd "s-Z")         'undo-tree-redo)

;; ---------------------------------------------------------------------------
;; Parens
;; ---------------------------------------------------------------------------
(electric-pair-mode 1)
(require 'paren)
(show-paren-mode 1)
(setq show-paren-delay 0)
(set-face-background 'show-paren-match (face-background 'default))
(if (eq (frame-parameter nil 'background-mode) 'dark)
    (set-face-foreground 'show-paren-match "red")
  (set-face-foreground 'show-paren-match "black"))
(set-face-attribute 'show-paren-match nil :weight 'extra-bold)

;; ---------------------------------------------------------------------------
;; Theme: doom-themes (doom-one)
;; ---------------------------------------------------------------------------
(use-package doom-themes
  :ensure t
  :config
  (setq doom-themes-enable-bold   t
        doom-themes-enable-italic t)
  (load-theme 'doom-one t)
  (doom-themes-visual-bell-config)
  (doom-themes-neotree-config)
  (doom-themes-org-config))

(set-face-attribute 'default nil :height 150)
(set-face-attribute 'isearch nil
                    :foreground "#000000"
                    :background "#ffff00")

;; ---------------------------------------------------------------------------
;; doom-modeline + nerd-icons (doom-modeline v4+ requires nerd-icons)
;; First-time: M-x nerd-icons-install-fonts
;; ---------------------------------------------------------------------------
(use-package nerd-icons :ensure t)

;; (use-package doom-modeline
;;   :ensure t
;;   :init (doom-modeline-mode 1)
;;   :custom
;;   (doom-modeline-height 28)
;;   ;; truncate-upto-root avoids calling projectile on every modeline redraw.
;;   (doom-modeline-buffer-file-name-style 'truncate-upto-root)
;;   (doom-modeline-icon t)
;;   (doom-modeline-major-mode-icon t))

;; ---------------------------------------------------------------------------
;; Completion: vertico + orderless + consult + marginalia
;; Replaces: ivy, counsel, swiper
;; ---------------------------------------------------------------------------
(use-package vertico
  :ensure t
  :init (vertico-mode)
  :custom
  (vertico-cycle t)
  (vertico-count 15))

(use-package orderless
  :ensure t
  :config
  ;; Teach orderless to treat "foo/bar" as fuzzy path: matches "foo.*bar" anywhere
  (defun my/orderless-path-dispatcher (pattern _index _total)
    "When PATTERN contains '/', match it as a fuzzy path component sequence."
    (when (string-match-p "/" pattern)
      `(orderless-regexp . ,(mapconcat #'regexp-quote
                                       (split-string pattern "/" t)
                                       ".*"))))
  (setq orderless-style-dispatchers '(my/orderless-path-dispatcher))
  :custom
  (completion-styles '(orderless basic))
  (completion-category-overrides '((file (styles basic partial-completion)))))

(use-package marginalia
  :ensure t
  :init (marginalia-mode))

;; Tell the compiler this is a special (dynamic) variable so let-binding it
;; below doesn't trigger the lexical-var warning.
(defvar consult-ripgrep-args)

(defun my-consult-ripgrep-dir ()
  "Run consult-ripgrep prompting for directory and optional exclude patterns."
  (interactive)
  (require 'consult)
  (let* ((dir      (read-directory-name "Ripgrep in dir: " default-directory))
         (excludes (read-string "Exclude globs, comma-separated (e.g. node_modules,*.test.ts) or blank: "))
         (glob-args (mapconcat (lambda (p) (format "--glob=!%s" p))
                               (split-string excludes "," t "\\s-*")
                               " "))
         (consult-ripgrep-args (concat consult-ripgrep-args
                                       (unless (string-blank-p glob-args)
                                         (concat " " glob-args)))))
    (consult-ripgrep dir "")))  ;; Only 2 args: DIR + INITIAL

(use-package consult
  :ensure t
  :bind (("C-s"     . consult-line)	; was swiper
         ("M-y"     . consult-yank-pop)	; was counsel-yank-pop
         ("C-x b"   . consult-buffer)
         ("C-c j"   . consult-git-grep)	      ; was counsel-git-grep
         ("C-c k"   . my-consult-ripgrep-dir) ; consult-ripgrep
         ("C-x l"   . consult-locate)	      ; was counsel-locate
         :map minibuffer-local-map
         ("C-r"     . consult-history))	; was counsel-minibuffer-history
  :custom
  (consult-project-function (lambda (_) (projectile-project-root)))
  :config
  (setq xref-show-xrefs-function       #'consult-xref
        xref-show-definitions-function #'consult-xref)
  ;; Don't preview on every arrow key — only after 0.5s idle or on M-.
  ;; Without this, navigating ripgrep results opens a file per keypress.
  (consult-customize
   consult-ripgrep consult-git-grep consult-grep
   :preview-key '(:debounce 0.5 any))
  (consult-customize
   consult-buffer consult-line
   :preview-key '(:debounce 0.3 any)))

(use-package savehist
  :ensure nil
  :init (savehist-mode))

;; ---------------------------------------------------------------------------
;; In-buffer completion: corfu + cape
;; Replaces: company
;; ---------------------------------------------------------------------------
(use-package corfu
  :ensure t
  :custom
  (corfu-auto        t)
  (corfu-auto-delay  0.2)
  (corfu-auto-prefix 2)
  (corfu-cycle       t)
  (corfu-quit-at-boundary nil)
  (corfu-quit-no-match    nil)
  (corfu-preselect        'prompt)
  (corfu-popupinfo-delay  '(0.5 . 0.3))
  (corfu-popupinfo-max-width  70)
  (corfu-popupinfo-max-height 20)
  :bind (:map corfu-map
              ("C-n" . corfu-next)
              ("C-p" . corfu-previous)
              ("M-t" . corfu-popupinfo-toggle))
  :init
  (global-corfu-mode)
  (corfu-popupinfo-mode)
  :config
  (set-face-attribute 'corfu-current nil
                      :background "#1a6bc4"
                      :foreground "#ffffff"
                      :weight 'bold)
  (set-face-attribute 'corfu-annotations nil
                      :foreground "#c8c8c8"))

(use-package nerd-icons-corfu
  :ensure t
  :after corfu
  :config
  (add-to-list 'corfu-margin-formatters #'nerd-icons-corfu-formatter))

(use-package cape
  :ensure t
  :init
  (add-to-list 'completion-at-point-functions #'cape-keyword)
  (add-to-list 'completion-at-point-functions #'cape-dabbrev)
  (add-to-list 'completion-at-point-functions #'cape-file)
  :config
  (setq cape-file-directory-must-exist nil)
  ;; Limit dabbrev to current buffer only — scanning all open buffers is very
  ;; slow in large dirs where you may have dozens of large files open.
  (setq cape-dabbrev-check-other-buffers nil)

  (defun my/cape-file-in-string-setup ()
    "Prepend string-aware cape-file to buffer-local completion-at-point-functions."
    (add-hook 'completion-at-point-functions
              (cape-capf-inside-string #'cape-file)
              -90
              t))

  (dolist (hook '(js-ts-mode-hook
                  tsx-ts-mode-hook
                  typescript-ts-mode-hook
                  go-mode-hook
                  python-ts-mode-hook))
    (add-hook hook #'my/cape-file-in-string-setup)))

(global-set-key (kbd "C-c C-/") #'completion-at-point)

;; ---------------------------------------------------------------------------
;; Navigation: ripgrep, ag, dumb-jump, projectile
;; ---------------------------------------------------------------------------
(use-package ripgrep :ensure t)

(use-package projectile-ripgrep
  :bind ("C-c g" . projectile-ripgrep))

(use-package ag
  :ensure t
  :commands (ag ag-files ag-regexp ag-project ag-dired)
  :config (setq ag-highlight-search t
                ag-reuse-buffers    t))

(use-package dumb-jump
  :ensure t
  :bind (("M-g o" . dumb-jump-go-other-window)
         ("M-g f" . dumb-jump-go)
         ("M-g b" . dumb-jump-back)
         ("M-g i" . dumb-jump-go-prompt)
         ("M-g x" . dumb-jump-go-prefer-external)
         ("M-g z" . dumb-jump-go-prefer-external-other-window))
  :config (setq dumb-jump-selector 'xref))

(use-package projectile
  :ensure t
  :defer 1
  :bind ("C-c p" . projectile-command-map)
  :config
  (projectile-global-mode)
  (setq projectile-completion-system 'default)
  (setq-default projectile-enable-caching t
                projectile-mode-line '(:eval (projectile-project-name)))
  ;; alien = git ls-files; it respects .gitignore but ignores the list below.
  ;; The list below only applies when indexing-method is 'hybrid or 'native.
  (dolist (dir '("node_modules" "dist" "build" ".next" ".turbo"
                 "coverage" ".cache" "__pycache__" ".git"))
    (add-to-list 'projectile-globally-ignored-directories dir))
  (setq projectile-indexing-method 'alien)
  ;; Don't scan git submodules — adds latency in large dirs.
  (setq projectile-git-submodule-command nil))

(global-set-key (kbd "s-t") 'projectile-find-file)
(global-set-key (kbd "s-g") 'projectile-grep)
(global-set-key (kbd "s-p") 'projectile-switch-project)

;; ---------------------------------------------------------------------------
;; Org Mode
;; ---------------------------------------------------------------------------
(use-package org-bullets
  :ensure t
  :config (add-hook 'org-mode-hook (lambda () (org-bullets-mode 1))))

;; ---------------------------------------------------------------------------
;; which-key (built-in since Emacs 30)
;; ---------------------------------------------------------------------------
(use-package which-key
  :ensure nil
  :config (which-key-mode))

;; ---------------------------------------------------------------------------
;; Flycheck
;; ---------------------------------------------------------------------------
(use-package flycheck
  :ensure t
  :custom
  (flycheck-check-syntax-automatically '(save idle-change))
  (flycheck-idle-change-delay 2.0)
  (flycheck-disabled-checkers '(javascript-eslint
                                javascript-jshint
                                javascript-standard
                                typescript-tslint))
  ;; Don't run globally — lsp-mode handles JS/TS/Go diagnostics.
  ;; Enable selectively only in modes that actually have useful checkers.
  :hook ((clojure-mode       . flycheck-mode)
         (clojurescript-mode . flycheck-mode)
         (python-ts-mode     . flycheck-mode)
         (sh-mode            . flycheck-mode)))

;; ---------------------------------------------------------------------------
;; Beacon
;; ---------------------------------------------------------------------------
(use-package beacon
  :ensure t
  :config
  (beacon-mode 1)
  (setq beacon-color                  "red"
        beacon-blink-delay            0.4
        beacon-blink-duration         0.4
        beacon-blink-when-point-moves 7
        beacon-push-mark              5
        beacon-size                   25))

;; ---------------------------------------------------------------------------
;; YASnippet
;; ---------------------------------------------------------------------------
(use-package yasnippet
  :ensure t
  :init (yas-global-mode 1))

;; ---------------------------------------------------------------------------
;; Undo Tree
;; ---------------------------------------------------------------------------
(use-package undo-tree
  :ensure t
  :custom
  (undo-tree-history-directory-alist '(("." . "~/.emacs.d/undo-tree-history")))
  :init (global-undo-tree-mode))

;; ---------------------------------------------------------------------------
;; Expand Region
;; ---------------------------------------------------------------------------
(use-package expand-region
  :ensure t
  :bind ("C-=" . er/expand-region))

;; ---------------------------------------------------------------------------
;; Tramp (built-in)
;; ---------------------------------------------------------------------------
(use-package tramp
  :ensure nil
  :defer 4
  :config (setq tramp-default-method "ssh"))

;; ---------------------------------------------------------------------------
;; all-the-icons (used by neotree)
;; First-time: M-x all-the-icons-install-fonts
;; ---------------------------------------------------------------------------
(use-package all-the-icons :ensure t)

;; ---------------------------------------------------------------------------
;; Neotree
;; ---------------------------------------------------------------------------
(use-package neotree
  :ensure t
  :config
  (global-set-key [f8] 'neotree-toggle)
  (setq neo-theme (if (display-graphic-p) 'icons 'arrow)))

;; ---------------------------------------------------------------------------
;; Aggressive Indent
;; ---------------------------------------------------------------------------
(use-package aggressive-indent
  :ensure t
  :config (global-aggressive-indent-mode 1))

;; ---------------------------------------------------------------------------
;; Rainbow Delimiters
;; ---------------------------------------------------------------------------
(use-package rainbow-delimiters
  :ensure t
  ;; Don't enable for treesitter-based modes — treesitter already provides
  ;; structural highlighting and rainbow-delimiters doubles the overlay work.
  :hook ((clojure-mode       . rainbow-delimiters-mode)
         (clojurescript-mode . rainbow-delimiters-mode)
         (emacs-lisp-mode    . rainbow-delimiters-mode)
         (python-ts-mode     . rainbow-delimiters-mode)))

;; ---------------------------------------------------------------------------
;; Multiple Cursors
;; ---------------------------------------------------------------------------
(use-package multiple-cursors
  :ensure t
  :bind (("C-S-c C-S-c" . mc/edit-lines)
         ("C->"         . mc/mark-next-like-this)
         ("C-<"         . mc/mark-previous-like-this)
         ("C-c C-<"     . mc/mark-all-like-this)))

;; ---------------------------------------------------------------------------
;; Delsel (built-in)
;; ---------------------------------------------------------------------------
(use-package delsel
  :ensure nil
  :config (delete-selection-mode t))

;; ---------------------------------------------------------------------------
;; Markdown Mode
;; ---------------------------------------------------------------------------
(use-package markdown-mode
  :ensure t
  :mode (("README\\.md\\'" . gfm-mode)
         ("\\.md\\'"       . markdown-mode)
         ("\\.markdown\\'" . markdown-mode))
  :init (setq markdown-command "multimarkdown")
  :config
  ;; Live preview opens in a side eww buffer inside Emacs.
  ;; C-c C-c p  toggles it (built into markdown-mode).
  (setq markdown-live-preview-delete-export 'delete-on-export)
  :bind (:map markdown-mode-map
              ("C-c C-p" . markdown-live-preview-mode)
              :map gfm-mode-map
              ("C-c C-p" . markdown-live-preview-mode)))

;; grip-mode: GitHub-accurate preview in browser (optional, needs: pip install grip).
;; Use when you need exact GitHub rendering.
(use-package grip-mode
  :ensure t
  :bind (:map markdown-mode-map
              ("C-c C-g" . grip-mode)
              :map gfm-mode-map
              ("C-c C-g" . grip-mode)))

;; markdown-toc: generate/update table of contents.
;; Usage: M-x markdown-toc-generate-toc
(use-package markdown-toc
  :ensure t)

;; ---------------------------------------------------------------------------
;; Ox-Reveal
;; ---------------------------------------------------------------------------
(use-package ox-reveal :ensure t)
(setq org-reveal-root    "http://cdn.jsdelivr.net/reveal.js/3.0.0/")
(setq org-reveal-mathjax t)

;; ---------------------------------------------------------------------------
;; Avy — fast char/word jump
;; ---------------------------------------------------------------------------
(use-package avy
  :ensure t
  :bind ("M-s" . avy-goto-char-timer))

;; ---------------------------------------------------------------------------
;; Helpful — richer Help buffers
;; ---------------------------------------------------------------------------
(use-package helpful
  :ensure t
  :bind (("C-h f" . helpful-callable)
         ("C-h v" . helpful-variable)
         ("C-h k" . helpful-key)
         ("C-h x" . helpful-command)))

;; ---------------------------------------------------------------------------
;; Embark + embark-consult — context actions on completion candidates
;; ---------------------------------------------------------------------------
(use-package embark
  :ensure t
  :bind (("C-," . embark-act)
         ("C-;" . embark-dwim)))

(use-package embark-consult
  :ensure t
  :hook (embark-collect-mode . consult-preview-at-point-mode))

;; ---------------------------------------------------------------------------
;; Wgrep — edit grep/ripgrep results inline (C-c C-p to make editable)
;; ---------------------------------------------------------------------------
(use-package wgrep
  :ensure t)

;; ---------------------------------------------------------------------------
;; Jinx — fast spell checker (requires: brew install enchant)
;; ---------------------------------------------------------------------------
;; (use-package jinx
;;   :ensure t
;;   :hook (emacs-startup . global-jinx-mode)
;;   :bind ("M-$" . jinx-correct))

;; ---------------------------------------------------------------------------
;; CSV Mode
;; ---------------------------------------------------------------------------
(use-package csv-mode
  :ensure t)

;; ---------------------------------------------------------------------------
;; Vterm — proper terminal emulator (requires: brew install cmake libvterm)
;; ---------------------------------------------------------------------------
(use-package vterm
  :ensure t
  :bind ("C-c t" . vterm))

;; ---------------------------------------------------------------------------
;; Esup (startup profiler)
;; ---------------------------------------------------------------------------
(use-package esup :ensure t)

;; ---------------------------------------------------------------------------
;; Symbol Overlay — highlight all occurrences of symbol at point
;; ---------------------------------------------------------------------------
(use-package symbol-overlay
  :ensure t
  ;; Don't auto-enable overlay mode globally — auto-highlighting on every cursor
  ;; move is expensive in large dirs. Use M-i to highlight on demand.
  :bind (("M-i" . symbol-overlay-put)
         ("M-n" . symbol-overlay-jump-next)
         ("M-p" . symbol-overlay-jump-prev)
         ("M-C" . symbol-overlay-remove-all)))

;; ---------------------------------------------------------------------------
;; Indent Bars — visual indent guides
;; ---------------------------------------------------------------------------
(use-package indent-bars
  :ensure t
  ;; prefer-character uses a plain Unicode bar character instead of bitmap
  ;; stipples. Stipple mode redraws every visible line on every scroll/redisplay;
  ;; character mode is significantly lighter (just a text glyph).
  :custom
  (indent-bars-prefer-character t)
  (indent-bars-no-descend-string t)
  :hook ((prog-mode . indent-bars-mode)
         (yaml-mode . indent-bars-mode)))

;; ---------------------------------------------------------------------------
;; Eldoc Box — LSP hover docs in a floating box
;; ---------------------------------------------------------------------------
(use-package eldoc-box
  :ensure t
  ;; Only enable when lsp is active — avoids post-command overhead on every buffer.
  :hook (lsp-mode . eldoc-box-hover-mode))

;; ---------------------------------------------------------------------------
;; Breadcrumb — file path + symbol breadcrumb in header line (via LSP)
;; ---------------------------------------------------------------------------
(use-package breadcrumb
  :ensure t
  :hook (lsp-mode . breadcrumb-mode))

;; ---------------------------------------------------------------------------
;; SQL / PostgreSQL
;; ---------------------------------------------------------------------------
(use-package sql-indent
  :ensure t
  :hook (sql-mode . sqlind-minor-mode))

(use-package sqlformat
  :ensure t
  :custom
  (sqlformat-command 'pgformatter)
  :hook (sql-mode . sqlformat-on-save-mode))

;; ---------------------------------------------------------------------------
;; Try (test packages without installing)
;; ---------------------------------------------------------------------------
(use-package try :ensure t :defer 4)
