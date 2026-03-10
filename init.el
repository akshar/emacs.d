;;; init.el --- Emacs 30 entry point -*- lexical-binding: t -*-

;; ---------------------------------------------------------------------------
;; Startup performance
;; ---------------------------------------------------------------------------
(setq gc-cons-threshold most-positive-fixnum)

(add-hook 'emacs-startup-hook
          (lambda ()
            ;; 64 MB — large enough to avoid GC pauses during normal editing.
            ;; 800 KB was causing constant pauses in large dirs.
            (setq gc-cons-threshold (* 64 1024 1024))
            (message "Emacs ready in %s with %d garbage collections."
                     (format "%.2f seconds"
                             (float-time
                              (time-subtract after-init-time before-init-time)))
                     gcs-done)))

(defun my-minibuffer-setup-hook ()
  (setq gc-cons-threshold most-positive-fixnum))

(defun my-minibuffer-exit-hook ()
  (setq gc-cons-threshold (* 64 1024 1024)))

(add-hook 'minibuffer-setup-hook #'my-minibuffer-setup-hook)
(add-hook 'minibuffer-exit-hook  #'my-minibuffer-exit-hook)

;; ---------------------------------------------------------------------------
;; Package archives
;; ---------------------------------------------------------------------------
(require 'package)
(setq package-check-signature nil)
(setq package-enable-at-startup nil)
(add-to-list 'package-archives '("melpa"  . "https://melpa.org/packages/"))
(add-to-list 'package-archives '("gnu"    . "https://elpa.gnu.org/packages/"))
(add-to-list 'package-archives '("nongnu" . "https://elpa.nongnu.org/packages/"))
(package-initialize)

;; use-package is built-in since Emacs 29 — no manual bootstrap needed.
(require 'use-package)
(setq use-package-always-ensure t)

;; ---------------------------------------------------------------------------
;; Load configuration modules
;; ---------------------------------------------------------------------------
(defun load-config (path)
  "Load PATH relative to `user-emacs-directory'."
  (let ((full-path (expand-file-name path user-emacs-directory)))
    (if (file-exists-p full-path)
        (load full-path nil 'nomessage)
      (warn "Config file not found: %s" full-path))))

;; Redirect Emacs custom writes to a separate ignored file.
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(when (file-exists-p custom-file) (load custom-file))

(load-config "config.el")
(load-config "lsp.el")
(load-config "lang/web.el")
(load-config "lang/clojure.el")
(load-config "lang/python.el")
(load-config "lang/GO.el")
(load-config "git/git.el")
(load-config "lang/devops.el")
(load-config "tools/rest.el")
(load-config "ai.el")
