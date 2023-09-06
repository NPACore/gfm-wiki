;;; package --- gfm-wiki

;;; Commentary:
;; Github Formated Markup untilities for flat directory markdown "wiki".
;; Provides: inserting markdown links and issues formated for github's markdown parser.
;; Requires 'git-bug' and 'jq' to find github issue number and pair with title for searching.
;; But we could wrap `gh issues' instead (see `gfm-wiki-issue-cmd').
;; 
;; for issue linking/rendering on github
;; `gfm-wiki-repo-name' is variable for storing the 'repo' in 'repo#issue'
;; 
;;
;; Consider link-hint for quickly jumping to pages with links.
;; TODO:
;;  * backlink search
;;  * header search and insert
;;  * deft or ag for link insert based on any matching text
;; 20230903WF - init

;;; Code:
(require 'ivy)
(require 'subr-x)

(defvar gfm-wiki-repo-name "NPACore/npac-interal"
  "Repo name for issue insert.  Translated by gollumn/github markdown render.")
(defvar gfm-wiki-issue-cmd
  "git bug ls -f json |
   jq -r '.[]|[(.metadata.\"github-url\"|gsub(\".*/\";\"\")), .title]|@tsv'"
  "Command to get issues.
Expect records to be new line spearated.
Fields 'number' and 'title' are tab separated.
As an alternative, consider formating 'gh issues'.")

(defun gfm-wiki-get-issues-gb ()
  "Use git-bug|jq to find issues number.  Could use 'gh issue'.
The returned list is tab seaprated with elements like \"number\ttitle\""
  (if-let* ((issues-str (shell-command-to-string gfm-wiki-issue-cmd))
            (issues (split-string issues-str "\n")))
      issues))

(defun gfm-wiki-insert-issue ()
  "Lookup issue number, prompt, and insert with `gfm-wiki-repo-name' prefix."
  (interactive)
  (if-let ((issue (ivy-completing-read "issue: " (gfm-wiki-get-issues-gb)))
           (issue-num (replace-regexp-in-string "\t.*" "" issue)))
           (insert (concat gfm-wiki-repo-name "#" issue-num))))

(defun gfm-wiki-insert-link ()
  "Insert link to markdown file chosen from current directory."
  (interactive)
  
  (if-let (;; 1. find md files
           (files  (directory-files "./" nil ".*.md"))
           ;; 2. prompt
           (file (ivy-completing-read "file: " files))
           (fname (replace-regexp-in-string "^./\\|.md$" "" file)))
      ;; 3. insert with  [file](file.md) warping
      (insert(concat "[" fname "]" "(" fname ".md)"))))

;; https://github.com/jrblevin/deft/issues/65
(defun gfm-wiki-deft ()
  "Use deft, but don't collied with global settings."
  (interactive)
  (if (get-buffer deft-buffer)
      (switch-to-buffer deft-buffer))
    (progn
      (deft)
      (setq-local deft-directory (file-name-directory (buffer-file-name)))
      (deft-refresh))
  (deft))

(provide 'gfm-wiki)

(defun gfm-wiki-insert-link-header ()
  (interactive)
  (if-let* ((file-header (split-string (shell-command-to-string "perl -lne 'print \"$ARGV#\".lc($1=~s/ /-/gr) if /^#+ (.*)/' *md") "\n"))
            (link (ivy-completing-read "link-to: " file-header)))
      (insert (concat "[](" link ")"))))
;;; gfm-wiki.el ends here