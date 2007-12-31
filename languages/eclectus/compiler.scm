; $Id$

; Generate driver and PAST for Eclectus

;; Helpers that emit PIR

; unique ids for registers
(define counter 1000)
(define (gen-unique-id)
  (set! counter (+ 1 counter))
  counter)

; Emit PIR that loads libs
(define (emit-init)
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
        " ) )

; Emit PIR that prints the value returned by scheme_entry()
(define (emit-driver)
  (emit "
        .sub drive :main
        
            .local pmc val_ret
            ( val_ret ) = scheme_entry()
            # _dumper( val_ret, 'val_ret' )
        
            .local pmc op_say
            op_say = new 'PAST::Op'
            op_say.init( val_ret, 'name' => 'say', 'pasttype' => 'call' )
        
            .local pmc stmts
            stmts = new 'PAST::Stmts'
            stmts.'init'( op_say, 'name' => 'stmts' )
        
            # compile and evaluate
            .local pmc past_compiler
            past_compiler = new [ 'PCT::HLLCompiler' ]
            $P0 = split ' ', 'post pir evalpmc'
            past_compiler.'stages'( $P0 )
            past_compiler.'eval'(stmts)
        
        .end
        " ))

; emit the PIR library
(define (emit-builtins)
  (emit "
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
        
        .sub 'infix:=='
            .param pmc a
            .param pmc b
            $I0 = cmp_num a, b
            $I0 = iseq $I0, 0
        
            .return ($I0)
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

        .sub 'infix:>'
            .param num a
            .param num b
            $I0 = isgt a, b

            .return ($I0)
        .end

        "))

; emit PIR for a scalar
(define (immediate-rep x)
  (cond
     [(fixnum? x)
      (format "
              val_x = new 'PAST::Val'
              val_x.init( 'value' => ~a, 'returns' => 'EclectusFixnum' )
              " x)]
     [(char? x)
      (format "
              val_x = new 'PAST::Val'
              val_x.init( 'value' => ~a, 'returns' => 'EclectusCharacter' )
              " (char->integer x) )]
     [(and (list? x) (= (length x) 0 ))
      "
      val_x = new 'PAST::Val'
      val_x.init( 'value' => 0, 'returns' => 'EclectusEmptyList' )
      " ]
     [(boolean? x)
        (if x 
            "
            val_x = new 'PAST::Val'
            val_x.init( 'value' => 1, 'returns' => 'EclectusBoolean' )
            "
            "
            val_x = new 'PAST::Val'
            val_x.init( 'value' => 0, 'returns' => 'EclectusBoolean' )
            ")]
     [(string? x)
      (format "
              val_x = new 'PAST::Val'
              val_x.init( 'value' => \"'~a'\", 'returns' => 'EclectusString' )
              " x)]))

;; recognition of forms

; forms represented by a scalar PMC
(define (immediate? expr)
  (or (fixnum? expr)
      (boolean? expr)
      (char? expr)
      (and (list? expr) (= (length expr) 0 ))))

(define make-combination-predicate
  (lambda (name)
    (lambda (form)
      (and (pair? form)
           (eq? name (car form))))))

(define if?
  (make-combination-predicate 'if))

(define if-test
  (lambda (form)
    (car (cdr form))))

(define if-conseq
  (lambda (form)
    (car (cdr (cdr form)))))

(define if-altern
  (lambda (form)
    (car (cdr (cdr (cdr form))))))

; Support for primitive functions

; is expr a primitive?
(define (primitive? expr)
  (and (symbol? expr) (getprop expr '*is-prim*)))

; is expr a call to a primitive? 
(define (primcall? expr)
  (and (pair? expr) (primitive? (car expr))))

; a primitive function is a symbol with the properties
; *is-prim*, *arg-count* and *emitter*
; implementatus of primitive functions are added
; with 'define-primitive'
(define-syntax define-primitive
  (syntax-rules ()
    [(_ (prim-name uid arg* ...) b b* ...)
     (begin
        (putprop 'prim-name '*is-prim*
          #t)
        (putprop 'prim-name '*arg-count*
          (length '(arg* ...)))
        (putprop 'prim-name '*emitter*
          (lambda (uid arg* ...) b b* ...)))]))

; implementation of fxadd1
(define-primitive (fxadd1 uid arg)
  (emit-expr arg)
  (emit "$P0 = val_x")
  (emit-immediate 1)
  (emit "
        $P1 = val_x
        val_x = new 'PAST::Op'
        val_x.init( $P0, $P1, 'pirop' => 'n_add' )
        "))

; implementation of fx+
(define-primitive (fx+ uid arg1 arg2)
  (emit "    .local pmc uniq_reg_1_~a, uniq_reg_2_~a " uid uid)
  (emit-expr arg1)
  (emit "uniq_reg_1_~a = val_x" uid)
  (emit-expr arg2)
  (emit "uniq_reg_2_~a = val_x" uid)
  (emit "
        val_x = new 'PAST::Op'
        val_x.init( uniq_reg_1_~a, uniq_reg_2_~a, 'pirop' => 'n_add' )
        " uid uid))

; implementation of fxsub1
(define-primitive (fxsub1 uid arg)
  (emit-expr arg)
  (emit "$P0 = val_x")
  (emit-immediate 1)
  (emit "
        $P1 = val_x
        val_x = new 'PAST::Op'
        val_x.init( $P0, $P1, 'pirop' => 'n_sub' )
        "))

; implementation of fx-
(define-primitive (fx- uid arg1 arg2)
  (emit "    .local pmc uniq_reg_1_~a, uniq_reg_2_~a " uid uid)
  (emit-expr arg1)
  (emit "uniq_reg_1_~a = val_x" uid)
  (emit-expr arg2)
  (emit "uniq_reg_2_~a = val_x" uid)
  (emit "
        val_x = new 'PAST::Op'
        val_x.init( uniq_reg_1_~a, uniq_reg_2_~a, 'pirop' => 'n_sub' )
        " uid uid))

; implementation of fxlogand
(define-primitive (fxlogand uid arg1 arg2)
  (emit "    .local pmc uniq_reg_1_~a, uniq_reg_2_~a " uid uid)
  (emit-expr arg1)
  (emit "uniq_reg_1_~a = val_x" uid)
  (emit-expr arg2)
  (emit "uniq_reg_2_~a = val_x" uid)
  (emit "
        val_x = new 'PAST::Op'
        val_x.init( uniq_reg_1_~a, uniq_reg_2_~a, 'pirop' => 'n_band' )
        " uid uid))

; implementation of fxlogor
(define-primitive (fxlogor uid arg1 arg2)
  (emit "    .local pmc uniq_reg_1_~a, uniq_reg_2_~a " uid uid)
  (emit-expr arg1)
  (emit "uniq_reg_1_~a = val_x" uid)
  (emit-expr arg2)
  (emit "uniq_reg_2_~a = val_x" uid)
  (emit "
        val_x = new 'PAST::Op'
        val_x.init( uniq_reg_1_~a, uniq_reg_2_~a, 'pirop' => 'n_bor' )
        " uid uid))


; implementation of char->fixnum
(define-primitive (char->fixnum uid arg)
  (emit-expr arg)
  (emit "
        $P0 = val_x
        val_x = new 'PAST::Op'
        val_x.init( $P0, 'pasttype' => 'inline', 'inline' => \"new %r, 'EclectusFixnum'\\nassign %r, %0\\n\" )
        "))

; implementation of fixnum->char
(define-primitive (fixnum->char uid arg)
  (emit-expr arg)
  (emit "
        $P0 = val_x
        val_x = new 'PAST::Op'
        val_x.init( $P0, 'pasttype' => 'inline', 'inline' => \"new %r, 'EclectusCharacter'\\nassign %r, %0\\n\" )
        "))

; implementation of fxzero?
(define-primitive (fxzero? uid arg)
  (emit-expr arg)
  (emit "$P0 = val_x")
  (emit-immediate 0)
  (emit "$P1 = val_x")
  (emit "
        $P4 = new 'PAST::Op'
        $P4.init( $P0, $P1, 'pasttype' => 'chain', 'name' => 'infix:==' ) 
        val_x = new 'PAST::Op'
        val_x.init( $P4, val_true, val_false, 'pasttype' => 'if'  )
        "))

; implementation of fx=
(define-primitive (fx= uid arg1 arg2)
  (emit "    .local pmc uniq_reg_1_~a, uniq_reg_2_~a " uid uid)
  (emit-expr arg1)
  (emit "uniq_reg_1_~a = val_x" uid)
  (emit-expr arg2)
  (emit "uniq_reg_2_~a = val_x" uid)
  (emit "
        $P4 = new 'PAST::Op'
        $P4.init( uniq_reg_1_~a, uniq_reg_2_~a, 'pasttype' => 'chain', 'name' => 'infix:==' ) 
        val_x = new 'PAST::Op'
        val_x.init( $P4, val_true, val_false, 'pasttype' => 'if'  )
        " uid uid))

; implementation of fx<
(define-primitive (fx< uid arg1 arg2)
  (emit "    .local pmc uniq_reg_1_~a, uniq_reg_2_~a " uid uid)
  (emit-expr arg1)
  (emit "uniq_reg_1_~a = val_x" uid)
  (emit-expr arg2)
  (emit "uniq_reg_2_~a = val_x" uid)
  (emit "
        $P4 = new 'PAST::Op'
        $P4.init( uniq_reg_1_~a, uniq_reg_2_~a, 'pasttype' => 'chain', 'name' => 'infix:<' ) 
        val_x = new 'PAST::Op'
        val_x.init( $P4, val_true, val_false, 'pasttype' => 'if'  )
        " uid uid))

; implementation of fx<=
(define-primitive (fx<= uid arg1 arg2)
  (emit "    .local pmc uniq_reg_1_~a, uniq_reg_2_~a " uid uid)
  (emit-expr arg1)
  (emit "uniq_reg_1_~a = val_x" uid)
  (emit-expr arg2)
  (emit "uniq_reg_2_~a = val_x" uid)
  (emit "
        $P4 = new 'PAST::Op'
        $P4.init( uniq_reg_1_~a, uniq_reg_2_~a, 'pasttype' => 'chain', 'name' => 'infix:<=' ) 
        val_x = new 'PAST::Op'
        val_x.init( $P4, val_true, val_false, 'pasttype' => 'if'  )
        " uid uid))

; implementation of fx>
(define-primitive (fx> uid arg1 arg2)
  (emit "    .local pmc uniq_reg_1_~a, uniq_reg_2_~a " uid uid)
  (emit-expr arg1)
  (emit "uniq_reg_1_~a = val_x" uid)
  (emit-expr arg2)
  (emit "uniq_reg_2_~a = val_x" uid)
  (emit "
        $P4 = new 'PAST::Op'
        $P4.init( uniq_reg_1_~a, uniq_reg_2_~a, 'pasttype' => 'chain', 'name' => 'infix:>' ) 
        val_x = new 'PAST::Op'
        val_x.init( $P4, val_true, val_false, 'pasttype' => 'if'  )
        " uid uid))


; implementation of null?
(define-primitive (null? uid arg)
  (emit-expr arg)
  (emit "$P0 = val_x")
  (emit "
        $P3 = new 'PAST::Op'
        $P3.init( $P0, 'pasttype' => 'inline', 'inline' => \"new %r, 'EclectusBoolean'\\n isa $I1, %0, 'EclectusEmptyList'\\n %r = $I1\" )
        val_x = new 'PAST::Op'
        val_x.init( $P3, val_true, val_false, 'pasttype' => 'if' )
        "))

; implementation of fixnum?
(define-primitive (fixnum? uid arg)
  (emit-expr arg)
  (emit "$P0 = val_x")
  (emit "
        $P3 = new 'PAST::Op'
        $P3.init( $P0, 'pasttype' => 'inline', 'inline' => \"new %r, 'EclectusBoolean'\\n isa $I1, %0, 'EclectusFixnum'\\n %r = $I1\" )
        val_x = new 'PAST::Op'
        val_x.init( $P3, val_true, val_false, 'pasttype' => 'if' )
        "))

; implementation of boolean?
(define-primitive (boolean? uid arg)
  (emit-expr arg)
  (emit "$P0 = val_x")
  (emit "
        $P3 = new 'PAST::Op'
        $P3.init( $P0, 'pasttype' => 'inline', 'inline' => \"new %r, 'EclectusBoolean'\\n isa $I1, %0, 'EclectusBoolean'\\n %r = $I1\" )
        val_x = new 'PAST::Op'
        val_x.init( $P3, val_true, val_false, 'pasttype' => 'if' )
        "))

; implementation of not?
; first check boolean? and then the inverse truthiness
(define-primitive (not? uid arg)
  (emit-expr arg)
  (emit "$P0 = val_x")
  (emit "
        $P3 = new 'PAST::Op'
        $P3.init( $P0, 'pasttype' => 'inline', 'inline' => \"new %r, 'EclectusBoolean'\\n isa $I1, %0, 'EclectusBoolean'\\n %r = $I1\" )
        $P4 = new 'PAST::Op'
        $P4.init( $P0, val_false, val_true, 'pasttype' => 'if' )
        val_x = new 'PAST::Op'
        val_x.init( $P3, $P4, val_false, 'pasttype' => 'if' )
        "))

; implementation of char?
(define-primitive (char? uid arg)
  (emit-expr arg)
  (emit "$P0 = val_x")
  (emit "
        $P3 = new 'PAST::Op'
        $P3.init( $P0, 'pasttype' => 'inline', 'inline' => \"new %r, 'EclectusBoolean'\\n isa $I1, %0, 'EclectusCharacter'\\n %r = $I1\" )
        val_x = new 'PAST::Op'
        val_x.init( $P3, val_true, val_false, 'pasttype' => 'if' )
        "))

; a getter of '*emitter*'
(define (primitive-emitter x)
  (getprop x '*emitter*))

(define (emit-function-header function-name)
  (emit (string-append ".sub " function-name))
  (emit "    .local pmc val_true, val_false, val_x")
  (emit-immediate #t)
  (emit "    val_true = val_x")
  (emit-immediate #f)
  (emit "    val_false = val_x")
)

(define (emit-function-footer)
  (emit "
          .return( val_x )
        .end
        "))

(define (emit-primcall expr)
  (let ([prim (car expr)] [args (cdr expr)])
    (apply (primitive-emitter prim) (gen-unique-id) args)))

(define (emit-immediate expr)
  (emit (immediate-rep expr)))

(define (emit-if expr uid)
  (emit "    .local pmc uniq_reg_if_test_~a, uniq_reg_if_conseq_~a, uniq_reg_if_altern_~a" uid uid uid)
  (emit-expr (if-test expr))
  (emit "uniq_reg_if_test_~a = val_x" uid)
  (emit-expr (if-conseq expr))
  (emit "uniq_reg_if_conseq_~a = val_x" uid)
  (emit-expr (if-altern expr))
  (emit "uniq_reg_if_altern_~a = val_x" uid)
  (emit "
        val_x = new 'PAST::Op'
        val_x.init( uniq_reg_if_test_~a, uniq_reg_if_conseq_~a, uniq_reg_if_altern_~a, 'pasttype' => 'if'  )
        " uid uid uid))
 
; emir PIR for an expression
(define (emit-expr expr)
  ; (display "# ")(write expr) (newline)
  (cond
    [(immediate? expr) (emit-immediate expr)]
    [(if? expr)        (emit-if expr (gen-unique-id))]
    [(primcall? expr)  (emit-primcall expr)]
  )) 

; transverse the program and rewrite
; "and" can be supported by transformation before compiling
; So "and" is implemented if terms of "if"
;
; Currently a new S-expression is generated,
; as I don't know how to manipulate S-expressions while traversing it
(define transform-and-or
  (lambda (tree)
    (cond [(atom? tree) tree]
          [(eqv? (car tree) 'and) 
            ( cond [(null? (cdr tree)) #t]
                   [(= (length (cdr tree)) 1) (transform-and-or (cadr tree))]
                   [else (quasiquote
                           (if
                            (unquote (transform-and-or (cadr tree)))
                            (unquote (transform-and-or (quasiquote (and (unquote-splicing (cddr tree))))))
                            #f))])]
          [(eqv? (car tree) 'or) 
            ( cond [(null? (cdr tree)) #f]
                   [(= (length (cdr tree)) 1) (transform-and-or (cadr tree))]
                   [else (quasiquote
                           (if
                            (unquote (transform-and-or (cadr tree)))
                            (unquote (transform-and-or (cadr tree)))
                            (unquote (transform-and-or (quasiquote (or (unquote-splicing (cddr tree))))))))])][else  (map transform-and-or tree)]))) 

; the actual compiler
(define (compile-program program)
  (emit-init)
  (emit-driver)
  (emit-builtins)
  (emit-function-header "scheme_entry")
  (emit-expr (transform-and-or program)) 
  (emit-function-footer))
