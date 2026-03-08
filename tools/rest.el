;;; tools/rest.el --- HTTP/REST client

(use-package restclient
  :ensure t
  :mode ("\\.http\\'" . restclient-mode))
