(ert-deftest gfm-wiki-test-mklink ()
  (let ((gfm-wiki-mkdocs-root nil))
    (should (string= (gfm-wiki-md-link "X" "Y.md") "[X](Y.md)"))))


(ert-deftest gfm-wiki-test-mklink-mkdocs ()
  (let ((gfm-wiki-mkdocs-root "/"))
    (should (string= (gfm-wiki-md-link "X" "Y.md#Z") "[X](/Y/#Z)"))))
