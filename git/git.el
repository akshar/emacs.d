(use-package git-gutter
  :ensure t
  :defer 2
  :custom
  (git-gutter:update-interval 0)
  ;; Empty list = no post-command updates at all.
  ;; We trigger manually via an idle timer after save so it never blocks a command.
  (git-gutter:update-commands '())
  :config
  (defun my/git-gutter-update-after-save ()
    (run-with-idle-timer 0.5 nil #'git-gutter))
  (add-hook 'after-save-hook #'my/git-gutter-update-after-save)
  :init (global-git-gutter-mode t))

(use-package git-timemachine
  :ensure t)

(use-package magit
  :bind ("C-x g" . magit-status)
  :config
  (setq
   magit-status-margin '(t "%Y-%m-%d %H:%M " magit-log-margin-width t 18)
   magit-commit-arguments nil
   magit-diff-use-overlays nil
   magit-diff-refine-hunk t))

;; ---------------------------------------------------------------------------
;; Forge — GitHub/GitLab PR & issue management inside magit
;; Prerequisite: add token to ~/.authinfo:
;;   machine api.github.com login <username>^forge password <token>
;; ---------------------------------------------------------------------------
(use-package forge
  :ensure t
  :after magit)
