; $Id$

(load "tests-driver.scm") ; this should come first

(add-tests-with-string-output "strings"      
)

(load "compiler.scm")
(test-all)
