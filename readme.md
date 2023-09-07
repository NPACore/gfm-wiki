# GFM-Wiki
Github flavored markdown "wiki" tools. Supports authoring interlinked pages and support for github issues linking.


This is developed for a github.com rendered repo with a flat-directory (no nested folders) containing markdown files that link to one another as well as internal github issues.

But it will likely also be useful on other markdown projects (`mkdocs`, `hugo`) as well.

## [Makefile](Makefile.example)
An example Makefile using `pandoc` to generate a giant interlinked pdf file from all markdown files.

## [wiki-lint.pl](wiki-lint.pl)
check file names, headers, and links between `*.md` files.

TODO: add line number and improve messages. maybe rewrite in compiled language.

1. file names are lowercase `-` separated `.md` files
2. first header in a file is also it's name (case insensitive, spaces translated to `-`)
   * does not check header rules for `readme.md` or `index.md`
3. all headers are uniquely named across all files
4. when `[blah][file.md#header1]` is written
   * `file.md` exists
   * `file.md` has some header named `header1` (line in file like `## header1`)
5. optionally: can check or "orphan" headers that are never linked to

### Example
```
echo -e "# testing\n## [dne](test.md#does-not-exist)" > test.md
wiki-lint.pl
```

> WANRING: test.md: first header should be match filename not 'testing'
>
> test.md: test.md#does-not-exist link does not exist 

## [gfm-wiki.el](gfm-wiki.el)

This file/emacs package contains functions for quickly linking topics between files.

### Install
Use <kbd>M-x</kbd> `list-packages` to install `quelpa-use-package`. then add below to e.g. `$HOME/.config/emacs/init.el`. 

```elisp
(use-package gfm-wiki
  :quelpa ((gfm-wiki :fetcher github :repo "NPACore/gfm-wiki") :upgrade t)
  :bind (:map markdown-mode-map
              ("C-c M-l" . #'gfm-wiki-insert-link-header)
              ("C-c M-L" . #'gfm-wiki-insert-link)
              ("C-c M-i" . #'gfm-wiki-insert-issue)
              ("C-c M-d" . #'gfm-wiki-deft)
              ;; other packages  -- better to define elsewhere
              ("C-c l"   . #'link-hint-open-link)
              ("C-c g"   . #'git-link)
              ))
```

### Variables
* `gfm-wiki-repo-name` contains the prefix for issues. github.com will render a link from anything thing that looks like `org/repo#id-num`. This variable stores the `org/repo` part. (The `id-num` is fetched by `gfm-wiki-insert-issue`)
  - consider `((markdown-mode . ((gfm-wiki-repo-name . "NPACore/gfm-wiki"))))` in `.dir-local.el`

* `gfm-wiki-insert-issue` command for getting issue number (to insert) and title (for search). Currently using `git-bug|jq` after `git bug bridge` with github. See [`Makefile.example`](Makefile.example)'s git-bug entry.

### Functions and Dependencies
* `gfm-wiki-insert-link-header` shells out to `perl` for finding headers.
* `gfm-wiki-insert-issues` uses [`git-bug`](https://github.com/MichaelMure/git-bug/) and `jq` to insert issues bridged to github.
* `gfm-wiki-deft` wraps emacs package [`deft`](https://github.com/jrblevin/deft) for a open/create files with search narrowing
Consider modify `gfm-wiki-issue-cmd` to use [`gh`](https://cli.github.com/) instead.
* The emacs package `ivy` is used for "completing-read" functions. 

### Other packages
* [`link-hint`](https://github.com/noctuid/link-hint.el/tree/36ce929331f2838213bcaa1145ece4b73ce84afe) is especially useful for quickly jumping from any link on the screen.
* [`git-link`](https://github.com/sshaw/git-link) to get or goto a github link of current file
