(require 'package)
(setq package-check-signature nil)
(setq package-enable-at-startup nil)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/"))
(add-to-list 'package-archives '("gnu" . "https://elpa.gnu.org/packages/"))

(package-initialize)


;;https://blog.d46.us/advanced-emacs-startup/
(setq gc-cons-threshold 50000000)


;;http://bling.github.io/blog/2016/01/18/why-are-you-changing-gc-cons-threshold/
(defun my-minibuffer-setup-hook ()
  (setq gc-cons-threshold most-positive-fixnum))

(defun my-minibuffer-exit-hook ()
  (setq gc-cons-threshold 800000))

(add-hook 'minibuffer-setup-hook #'my-minibuffer-setup-hook)
(add-hook 'minibuffer-exit-hook #'my-minibuffer-exit-hook)


(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(org-babel-load-file (expand-file-name "~/.emacs.d/config.org"))
(org-babel-load-file (expand-file-name "~/.emacs.d/lang/web.org"))
(org-babel-load-file (expand-file-name "~/.emacs.d/lang/clojure.org"))
(org-babel-load-file (expand-file-name "~/.emacs.d/lang/python.org"))
(org-babel-load-file (expand-file-name "~/.emacs.d/git/git.org"))


