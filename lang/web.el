(use-package web-mode
  :ensure t
  :defer t
  :hook (web-mode . (lambda ()
                      ;; buffer-local: only indents in web-mode buffers
                      (add-hook 'before-save-hook 'web-mode-buffer-indent nil t)))
  :mode (("\\.html?\\'" . web-mode)
	     ("\\.css?\\'" . web-mode)
	     ("\\.mustache\\'" . web-mode)
	     ("\\.erb\\'" . web-mode))
  :config
  (setq-default indent-tabs-mode nil)
  (setq web-mode-markup-indent-offset 2)
  (setq web-mode-code-indent-offset 2)
  (setq web-mode-css-indent-offset 2)
  (setq web-mode-script-padding 0)
  (setq web-mode-enable-auto-expanding t)
  (setq web-mode-enable-css-colorization t)
  (setq web-mode-enable-auto-pairing nil)
  (setq web-mode-enable-auto-closing t)
  (setq web-mode-enable-auto-quoting t)
  (setq web-mode-auto-close-style 2)      ;;close after opening-tag
  (setq web-mode-auto-quote-style 2))     ;;use single-quotes for attributes(requires v15)

(use-package treesit-auto
  :ensure t
  :custom
  ;; 'prompt instead of t — auto t blocks file open to download grammars.
  ;; Run M-x treesit-auto-install-all once to pre-install all grammars.
  (treesit-auto-install 'prompt)
  :config
  (treesit-auto-add-to-auto-mode-alist '(typescript tsx javascript json))
  (global-treesit-auto-mode))

(setq typescript-ts-mode-indent-offset 2)
(setq js-indent-level 2)

(dolist (hook '(typescript-ts-mode-hook tsx-ts-mode-hook js-ts-mode-hook))
  (add-hook hook (lambda () (aggressive-indent-mode -1))))

(use-package apheleia
  :ensure t
  :config
  ;; Use prettier directly (not via npx) — npx adds 300-500ms per format call
  ;; because it resolves the package registry. Apheleia already resolves the
  ;; nearest node_modules/.bin binary automatically when using "prettier" here.
  (setf (alist-get 'prettier apheleia-formatters)
        '("prettier" "--stdin-filepath" filepath))
  (dolist (entry '((typescript-ts-mode . prettier)
                   (tsx-ts-mode        . prettier)
                   (js-ts-mode         . prettier)
                   (json-ts-mode       . prettier)
                   (css-mode           . prettier)
                   (scss-mode          . prettier)))
    (setf (alist-get (car entry) apheleia-mode-alist) (cdr entry)))
  (apheleia-global-mode +1))

(use-package emmet-mode
  :ensure t
  :config
  (add-hook 'sgml-mode-hook 'emmet-mode)
  (add-hook 'web-mode-hook 'emmet-mode)
  (add-hook 'tsx-ts-mode-hook 'emmet-mode)
  (add-hook 'css-mode-hook 'emmet-mode))

(use-package css-mode
  :ensure nil
  :init (setq css-indent-offset 2))

;; scss-mode is built into css-mode.el (feature name is css-mode, not scss-mode)
(setq scss-compile-at-save nil)

(use-package css-eldoc
  :commands turn-on-css-eldoc
  :hook ((css-mode scss-mode less-css-mode) . turn-on-css-eldoc))

(use-package json-mode
  :ensure t
  :mode (("\\.tmpl\\'" . json-mode)
	     ("\\.eslintrc\\'" . json-mode))
  :config (setq-default js-indent-level 2))

(use-package json-reformat
  :ensure t
  :after json-mode
  :bind (("C-c r" . json-reformat-region)))

(use-package yaml-mode
  :ensure t
  :mode ("\\.ya?ml\\'" . yaml-mode))
