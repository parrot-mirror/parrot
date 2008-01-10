; $Id$

(load "tests-driver.scm") ; this should come first

(add-tests-with-string-output "local variables"
  [((lambda () 18))                                       => "18\n"]     
  [((lambda () (fx- 20 2)))                               => "18\n"]     
  [((lambda () (fx- 36 (fx- 20 2))))                      => "18\n"]     
)

(load "compiler.scm")
(test-all)
