;;; lang/devops.el --- Docker, Terraform, Nginx

(use-package dockerfile-mode
  :ensure t)

(use-package terraform-mode
  :ensure t
  :hook (terraform-mode . lsp-deferred))

(use-package nginx-mode
  :ensure t)
