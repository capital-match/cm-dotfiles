;; General layout

(global-set-key "\C-cg" 'goto-line)

;; form http://stackoverflow.com/questions/2903426/display-path-of-file-in-status-bar
(require 'uniquify)
(setq uniquify-buffer-name-style 'reverse)

;; Haskell stuff
;; Prepend bin and .cabal/bin to PATH environment variable 
(setenv "PATH" (concat (getenv "HOME") "/.cabal/bin:" (getenv "PATH")))

;; Prepend them to `exec-path'
(setq exec-path
      (reverse
       (append
        (reverse exec-path)
        (list (concat (getenv "HOME") "/.cabal/bin")))))

(menu-bar-mode 0)
(tool-bar-mode 0)

(global-set-key (kbd "C-c C-/") 'comment-or-uncomment-region)

;; package installation
(require 'package)
(add-to-list 'package-archives
             '("marmalade" . "http://marmalade-repo.org/packages/"))
(add-to-list 'package-archives
             '("melpa" . "http://melpa-stable.milkbox.net/packages/"))

(package-initialize)

;; multiple-cursors
;; https://github.com/magnars/multiple-cursors.el

(require 'multiple-cursors)

(global-set-key (kbd "C->") 'mc/mark-next-like-this)
(global-set-key (kbd "C-<") 'mc/mark-previous-like-this)
(global-set-key (kbd "C-c C-<") 'mc/mark-all-like-this)
(global-set-key (kbd "C-S-c C-S-c") 'mc/edit-lines)

;; flx
(require 'flx-ido)
(ido-mode 1)
(ido-everywhere 1)
(flx-ido-mode 1)

;; disable ido faces to see flx highlights.
(setq ido-use-faces nil)

;; use space for indentation, 2 spaces wide
(setq-default indent-tabs-mode nil)
(setq-default tab-width 2)

;; activate smerge when opening conflict files
(defun sm-try-smerge ()
     (save-excursion
       (goto-char (point-min))
       (when (re-search-forward "^<<<<<<< " nil t)
   	   (smerge-mode 1))))

(add-hook 'find-file-hook 'sm-try-smerge t)

;; haskell coding
(require 'auto-complete)
(require 'haskell-mode)
(require 'haskell-cabal)

(defun comint-write-history-on-exit (process event)
  (comint-write-input-ring)
  (let ((buf (process-buffer process)))
    (when (buffer-live-p buf)
      (with-current-buffer buf
        (insert (format "\nProcess %s %s" process event))))))

(defun turn-on-comint-history ()
  (let ((process (get-buffer-process (current-buffer))))
    (when process
      (setq comint-input-ring-file-name
            (format "~/.emacs.d/inferior-%s-history"
                    (process-name process)))
      (comint-read-input-ring)
      (set-process-sentinel process
                            #'comint-write-history-on-exit))))

(autoload 'ghc-init "ghc" nil t)
(autoload 'ghc-debug "ghc" nil t)
(add-hook 'haskell-mode-hook (lambda () (ghc-init)))
(setq ghc-debug t)

(eval-after-load "haskell-mode"
  '(progn
     (setq haskell-stylish-on-save t)
     (setq haskell-tags-on-save t)

     (setq haskell-process-type 'cabal-repl)
     (setq haskell-process-args-cabal-repl '("--ghc-option=-ferror-spans")) 
     
     (define-key haskell-mode-map (kbd "C-,") 'haskell-move-nested-left)
     (define-key haskell-mode-map (kbd "C-.") 'haskell-move-nested-right)
     (define-key haskell-mode-map (kbd "C-c v c") 'haskell-cabal-visit-file)
     (define-key haskell-mode-map (kbd "C-c v c") 'haskell-cabal-visit-file)
     (define-key haskell-mode-map (kbd "C-c C-t") 'ghc-show-type)
     (define-key haskell-mode-map (kbd "C-x C-d") nil)
     (setq haskell-font-lock-symbols t)

     ;; Do this to get a variable in scope
     (auto-complete-mode)

     ;; from http://pastebin.com/tJyyEBAS
     (ac-define-source ghc-mod
       '((depends ghc)
         (candidates . (ghc-select-completion-symbol))
         (symbol . "s")
         (cache)))
     
     (defun my-ac-haskell-mode ()
       (setq ac-sources '(ac-source-words-in-same-mode-buffers
                          ac-source-dictionary
                          ac-source-ghc-mod)))
     (add-hook 'haskell-mode-hook 'my-ac-haskell-mode)
     
  
     (defun my-haskell-ac-init ()
       (when (member (file-name-extension buffer-file-name) '("hs" "lhs"))
         (auto-complete-mode t)
         (setq ac-sources '(ac-source-words-in-same-mode-buffers
                            ac-source-dictionary
                            ac-source-ghc-mod))))
     (add-hook 'find-file-hook 'my-haskell-ac-init)))

(add-hook 'haskell-mode-hook 'turn-on-haskell-decl-scan)
(add-hook 'haskell-mode-hook 'turn-on-haskell-indentation)
(add-hook 'haskell-mode-hook 'interactive-haskell-mode)

(add-hook 'haskell-interactive-mode-hook 'turn-on-comint-history)

(eval-after-load "which-func"
  '(add-to-list 'which-func-modes 'haskell-mode))

(eval-after-load "haskell-cabal"
    '(define-key haskell-cabal-mode-map (kbd "C-c C-c") 'haskell-compile))
