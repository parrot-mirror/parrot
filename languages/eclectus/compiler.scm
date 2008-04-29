; $Id$

; Generate driver and PAST for Eclectus

;; Helpers that emit PIR

; unique ids for registers
(define counter 1000)
(define (gen-unique-id)
  (set! counter (+ 1 counter))
  counter)

(define (make-past-conser type)
  (let ((type-symbol (string->symbol type)))
    (lambda args
      (cons type-symbol args))))

(define past::op (make-past-conser "PAST::Op"))
(define past::val (make-past-conser "PAST::Val"))
(define past::var (make-past-conser "PAST::Var"))
(define past::block (make-past-conser "PAST::Block"))
(define past::stmts
  (let ((type-symbol (string->symbol "PAST::Stmts")))
    (lambda (stmts)
      (cons type-symbol stmts))))

; Emit PIR that loads libs
(define emit-init
  (lambda ()
    (emit "
          # PIR generated by compiler.scm
          
          # The dynamics PMCs used by Eclectus are loaded
          .loadlib 'eclectus_group'
          
          # for devel
          .include 'library/dumper.pir'
          
          .namespace
          
          .sub '__onload' :init
              load_bytecode 'PGE.pbc'
              load_bytecode 'PGE/Text.pbc'
              load_bytecode 'PGE/Util.pbc'
              load_bytecode 'PGE/Dumper.pbc'
              load_bytecode 'PCT.pbc'
          .end
          ")))

; Emit PIR that prints the value returned by scheme_entry()
(define emit-driver
  (lambda ()
    (emit "
          .sub drive :main
          
              .local pmc stmts
              ( stmts ) = scheme_entry()
              # _dumper( stmts, 'stmts' )
          
              # compile and evaluate
              .local pmc past_compiler
              past_compiler = new [ 'PCT::HLLCompiler' ]
              $P0 = split ' ', 'post pir'
              past_compiler.'stages'( $P0 )
              $P1 = past_compiler.'eval'(stmts)
              #_dumper ($P1)
              $P0 = split ' ', 'evalpmc'
              past_compiler.'stages'( $P0 )
              past_compiler.'eval'( $P1 )
          .end
          ")))

; emit the PIR library
(define emit-builtins
  (lambda ()
    (emit "
          .sub '__initconst' :init
              $P0 = new 'EclectusBoolean'
              $P0 = 1
              set_root_global ['_eclectus'], '#t', $P0
              $P0 = new 'EclectusBoolean'
              set_root_global ['_eclectus'], '#f', $P0
              $P0 = new 'EclectusEmptyList'
              set_root_global ['_eclectus'], '()', $P0
          .end

          .sub 'say'
              .param pmc args :slurpy
              if null args goto end
              .local pmc iter
              iter = new 'Iterator', args
          loop:
              unless iter goto end
              $P0 = shift iter
              print $P0
              goto loop
          end:
              say ''
              .return ()
          .end
          
          .sub 'infix:<'
              .param num a
              .param num b
              $I0 = islt a, b

              .return ($I0)
          .end

          .sub 'infix:<='
              .param num a
              .param num b
              $I0 = isle a, b

              .return ($I0)
          .end

          .sub 'infix:=='
              .param pmc a
              .param pmc b
              $I0 = cmp_num a, b
              $I0 = iseq $I0, 0
          
              .return ($I0)
          .end

          .sub 'infix:>='
              .param num a
              .param num b
              $I0 = isge a, b

              .return ($I0)
          .end

          .sub 'infix:>'
              .param num a
              .param num b
              $I0 = isgt a, b

              .return ($I0)
          .end

          .sub 'eq?'
              .param pmc a
              .param pmc b
              $I0 = issame a, b

              .return ($I0)
          .end

          .sub 'eqv?'
              .param pmc a
              .param pmc b
              $I0 = iseq a, b

              .return ($I0)
          .end

          .sub 'equal?'
              .param pmc a
              .param pmc b
              $I0 = iseq a, b

              .return ($I0)
          .end
          ")))

; recognition of forms
(define make-combination-predicate
  (lambda (name)
    (lambda (form)
      (and (pair? form)
           (eq? name (car form))))))

(define if?     (make-combination-predicate 'if))
(define let?    (make-combination-predicate 'let))
(define lambda? (make-combination-predicate 'lambda))
(define begin?  (make-combination-predicate 'begin))
(define quote?  (make-combination-predicate 'quote))

(define if-test
  (lambda (form)
    (car (cdr form))))

(define if-conseq
  (lambda (form)
    (car (cdr (cdr form)))))

(define if-altern
  (lambda (form)
    (car (cdr (cdr (cdr form))))))

(define (self-evaluating? x)
  (or (string? x)
      (number? x)
      (char? x)
      (boolean? x)))

; Support for primitive functions

(define-record-type primitive
  (make-primitive arg-count emitter)
  primitive?
  (arg-count primitive-arg-count)
  (emitter primitive-emitter))

(define *primitives* (make-eq-hashtable))

(define (lookup-primitive sym)
  (hashtable-ref *primitives* sym #f))

; is x a call to a primitive? 
(define primcall?
  (lambda (x)
    (and (pair? x) (lookup-primitive (car x)))))

; implementatus of primitive functions are added
; with 'define-primitive'
(define-syntax define-primitive
  (syntax-rules ()
    ((_ (prim-name arg* ...) b b* ...)
     (hashtable-set! *primitives*
                     'prim-name
                     (make-primitive (length '(arg* ...))
                                     (lambda (arg* ...) b b* ...))))))

; implementation of fxadd1
(define-primitive (fxadd1 arg)
  (past::op '(@ (pirop "n_add"))
            (emit-expr arg)
            (emit-expr 1)))

; implementation of fx+
(define-primitive (fx+ arg1 arg2)
  (past::op '(@ (pirop "n_add"))
            (emit-expr arg1)
            (emit-expr arg2)))

; implementation of fxsub1
(define-primitive (fxsub1 arg)
  (past::op
        '(@ (pirop "n_sub"))
        (emit-expr arg)
        (emit-expr 1)))

; implementation of fx-
(define-primitive (fx- arg1 arg2)
  (past::op '(@ (pirop "n_sub"))
            (emit-expr arg1)
            (emit-expr arg2)))

; implementation of fxlogand
(define-primitive (fxlogand arg1 arg2)
  (past::op '(@ (pirop "n_band"))
            (emit-expr arg1)
            (emit-expr arg2)))

; implementation of fxlogor
(define-primitive (fxlogor arg1 arg2)
  (past::op '(@ (pirop "n_bor"))
            (emit-expr arg1)
            (emit-expr arg2)))

; implementation of char->fixnum
(define-primitive (char->fixnum arg)
  (past::op '(@ (pasttype "inline")
                (inline "new %r, 'EclectusFixnum'\\nassign %r, %0\\n"))
            (emit-expr arg)))

; implementation of fixnum->char
(define-primitive (fixnum->char arg)
  (past::op '(@ (pasttype "inline")
                (inline "new %r, 'EclectusCharacter'\\nassign %r, %0\\n"))
            (emit-expr arg)))

; implementation of cons
(define-primitive (cons arg1 arg2)
  (past::op '(@ (pasttype "inline")
                (inline "new %r, 'EclectusPair'\\nset %r[%0], %1\\n"))
            (emit-expr arg1)
            (emit-expr arg2)))

; implementation of car
(define-primitive (car arg)
  (past::op '(@ (pasttype "inline")
                (inline "%r = %0.'key'()\\n"))
            (emit-expr arg)))

; implementation of cdr
(define-primitive (cdr arg)
  (past::op '(@ (pasttype "inline")
                (inline "%r = %0.'value'()\\n"))
            (emit-expr arg)))

(define emit-comparison
  (lambda (builtin arg1 arg2)
    (past::op '(@ (pasttype "if"))
              (past::op `(@ (pasttype "chain")
                            (name ,builtin))
                        (emit-expr arg1)
                        (emit-expr arg2))
              (emit-expr #t)
              (emit-expr #f))))

; implementation of char<
(define-primitive (char< arg1 arg2)
  (emit-comparison "infix:<" arg1 arg2))

; implementation of char<=
(define-primitive (char<= arg1 arg2)
  (emit-comparison "infix:<=" arg1 arg2))

; implementation of char=
(define-primitive (char= arg1 arg2)
  (emit-comparison "infix:==" arg1 arg2))

; implementation of char>
(define-primitive (char> arg1 arg2)
  (emit-comparison "infix:>" arg1 arg2))

; implementation of char>=
(define-primitive (char>= arg1 arg2)
  (emit-comparison "infix:>=" arg1 arg2))

; implementation of fxzero?
(define-primitive (fxzero? arg)
  (emit-comparison "infix:==" arg 0))

; implementation of fx<
(define-primitive (fx< arg1 arg2)
  (emit-comparison "infix:<" arg1 arg2))

; implementation of fx<=
(define-primitive (fx<= arg1 arg2)
  (emit-comparison "infix:<=" arg1 arg2))

; implementation of fx=
(define-primitive (fx= arg1 arg2)
  (emit-comparison "infix:==" arg1 arg2))

; implementation of fx>=
(define-primitive (fx>= arg1 arg2)
  (emit-comparison "infix:>=" arg1 arg2))

; implementation of fx>
(define-primitive (fx> arg1 arg2)
  (emit-comparison "infix:>" arg1 arg2))

(define-primitive (eq? arg1 arg2)
  (emit-comparison "eq?" arg1 arg2))

(define-primitive (eqv? arg1 arg2)
  (emit-comparison "eqv?" arg1 arg2))

(define-primitive (equal? arg1 arg2)
  (emit-comparison "equal?" arg1 arg2))

(define-primitive (not arg)
  (emit-comparison "eq?" arg #f))

; asking for the type of an object
(define emit-typequery
  (lambda (typename arg)
    (past::op
     '(@ (pasttype "if"))
     (past::op
      `(@ (pasttype "inline")
          (inline ,(format #f "new %r, 'EclectusBoolean'\\nisa $I1, %0, '~a'\\n %r = $I1" typename)))
      (emit-expr arg))
     (emit-expr #t)
     (emit-expr #f))))
   
(define-primitive (boolean? arg)
  (emit-typequery "EclectusBoolean" arg))

(define-primitive (char? arg)
  (emit-typequery "EclectusCharacter" arg))

(define-primitive (null? arg)
  (emit-typequery "EclectusEmptyList" arg))

(define-primitive (fixnum? arg)
  (emit-typequery "EclectusFixnum" arg))

(define-primitive (pair? arg)
  (emit-typequery "EclectusPair" arg))



(define emit-function-header
  (lambda (function-name)
    (emit (string-append ".sub " function-name))))

(define emit-function-footer
  (lambda (reg)
    (emit "
            .return( reg_~a )
          .end
          " reg)))

(define emit-primcall
  (lambda (x)
    (let ((prim (lookup-primitive (car x))) (args (cdr x)))
      (apply (primitive-emitter prim) args))))

(define emit-functional-application
  (lambda (x)
    (append
      (past::op '(@ (pasttype "call"))
                (emit-expr (car x)))
      (map
       (lambda (arg)
         (emit-expr arg))
       (cdr x)))))

(define (emit-variable x)
  (past::var `(@ (name ,x)
                 (scope "lexical")
                 (viviself "Undef"))))

(define (emit-constant x)
  (cond
   ((fixnum? x)
    (past::val `(@ (value ,x)
                   (returns "EclectusFixnum"))))
   ((char? x)
    (past::val `(@ (value ,(char->integer x))
                   (returns "EclectusCharacter"))))
   ((null? x)
    (emit-global-ref "()"))
   ((boolean? x)
    (emit-global-ref (if x "#t" "#f")))
   ((string? x)
    (past::val `(@ (value (unquote (format #f "'~a'" x)))
                   (returns "EclectusString"))))
   ((vector? x)
    (past::val '(@ (value "'#0()'")
                   (returns "EclectusString"))))))


(define (emit-global-ref name)
  (past::op `(@ (pasttype "inline")
                (inline ,(format #f "%r = get_root_global ['_eclectus'], '~a'" name)))))

(define bindings
  (lambda (x)
    (cadr x)))

(define body
  (lambda (x)
    (caddr x)))

(define emit-variable
  (lambda (x)
    (past::var (quasiquote (@ (name (unquote x))
                              (scope "lexical")
                              (viviself "Undef"))))))

(define emit-if
  (lambda (x)
    (past::op
     '(@ (pasttype "if"))
     (emit-expr (if-test x))
     (emit-expr (if-conseq x))
     (emit-expr (if-altern x)))))

(define emit-lambda
  (lambda (x)  
    ; (write (list "all" x "decl" (cadr x) "stmts" (cddr x) ))(newline)
    (past::block
     (quasiquote (@ (blocktype "declaration")
                    (arity (unquote (length (cadr x))))))
     (past::stmts (map
                   (lambda (decl)
                     (past::var
                      (quasiquote (@ (name (unquote decl))
                                     (scope "parameter")))))
                   (cadr x)))
     (past::stmts (map
                   (lambda (stmt)
                     (emit-expr stmt))
                   (cddr x))))))

(define emit-begin
  (lambda (x)
    (past::stmts (map emit-expr (cdr x)))))

; emir PIR for an expression
(define emit-expr
  (lambda (x)
    ;(diag (format "emit-expr: ~s" x))
    (cond
      ((symbol? x)          (emit-variable x))
      ((quote? x)           (emit-constant (cadr x)))
      ((self-evaluating? x) (emit-constant x))
      ((if? x)              (emit-if x))
      ((begin? x)           (emit-begin x))
      ((lambda? x)          (emit-lambda x))
      ((primcall? x)        (emit-primcall x))
      (else                 (emit-functional-application x)))))

; eventually this will become a PIR generator
; for PAST as SXML
; currently it only handles the pushes
(define past-sxml->past-pir
  (lambda (past)
    (let ((uid (gen-unique-id)))
      ;(diag (format "to_pir: ~a" past))
      (emit "
            .local pmc reg_~a
            reg_~a = new '~a'
            " uid uid (symbol->string (car past)))
      (for-each
        (lambda (daughter)
          (if (eq? '@ (car daughter))
            (for-each
              (lambda (key_val)
                (emit "
                      reg_~a.init( '~a' => \"~a\" )
                      " uid (car key_val) (cadr key_val)))
                (cdr daughter))
              (emit "
                    reg_~a.push( reg_~a )
                    " uid (past-sxml->past-pir daughter))))
        (cdr past))
      uid)))

; eventually this will become a NQP generator
; for PAST as SXML
; currently it only handles the pushes
(define past-sxml->past-nqp
  (lambda (past)
    (if (symbol? (car past))
        (emit "
                ~a.new( 
              " (symbol->string (car past))))
    (for-each
       (lambda (daughter)
         (if (eq? '@ (car daughter))
           (for-each
             (lambda (key_val)
               (emit "
                     :~a(\"~a\"),
                     " (car key_val) (cadr key_val)))
             (cdr daughter))
           (past-sxml->past-nqp daughter)))
       (cdr past))
    (emit ")")))

; print the result of the evaluation
(define wrap-say
  (lambda (past)
    (past::op
     '(@ (pasttype "call")
         (name "say"))
     past)))

;; Macro-expansion and alpha-conversion
(define (normalize-syntax program)
  (sexp/expand program (make-sexp-environment)))

; the current compiler, emitting PAST set up in PIR
(define compile-program-old
  (lambda (program)
    (emit-init)
    (emit-driver)
    (emit-builtins)
    (emit-function-header "scheme_entry")
    (emit-function-footer
      (past-sxml->past-pir
        (wrap-say
          (emit-expr (normalize-syntax program)))))))

; the future compiler, emitting PAST set up in PIR
(define compile-program
  (lambda (program)
    (emit "sub scheme_entry () { " ) 
    (past-sxml->past-nqp
      (wrap-say
        (emit-expr (normalize-syntax program))))
    (emit "; }" ))) 
