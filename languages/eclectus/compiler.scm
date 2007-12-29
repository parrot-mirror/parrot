; $Id$

; Generate driver and PAST for Eclectus

;; Helpers that emit PIR

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

; a unary function is a symbol with the properties
; *is-prim*, *arg-count* and *emitter*
; implementatus of primitive functions are added
; with 'define-primitive'
(define-syntax define-primitive
  (syntax-rules ()
    [(_ (prim-name arg) b b* ...)
     (begin
        (putprop 'prim-name '*is-prim*
          #t)
        (putprop 'prim-name '*arg-count*
          (length '(arg)))
        (putprop 'prim-name '*emitter*
          (lambda (arg) b b* ...)))]))

; implementation of fxadd1
(define-primitive (fxadd1 arg)
  (emit-expr arg)
  (emit "$P0 = val_x")
  (emit-immediate 1)
  (emit "
        $P1 = val_x
        val_x = new 'PAST::Op'
        val_x.init( $P0, $P1, 'pirop' => 'n_add' )
        "))

; implementation of fxsub1
(define-primitive (fxsub1 arg)
  (emit-expr arg)
  (emit "$P0 = val_x")
  (emit-immediate 1)
  (emit "
        $P1 = val_x
        val_x = new 'PAST::Op'
        val_x.init( $P0, $P1, 'pirop' => 'n_sub' )
        "))

; implementation of char->fixnum
(define-primitive (char->fixnum arg)
  (emit-expr arg)
  (emit "
        $P0 = val_x
        val_x = new 'PAST::Op'
        val_x.init( $P0, 'pasttype' => 'inline', 'inline' => \"new %r, 'EclectusFixnum'\\nassign %r, %0\\n\" )
        "))

; implementation of fixnum->char
(define-primitive (fixnum->char arg)
  (emit-expr arg)
  (emit "
        $P0 = val_x
        val_x = new 'PAST::Op'
        val_x.init( $P0, 'pasttype' => 'inline', 'inline' => \"new %r, 'EclectusCharacter'\\nassign %r, %0\\n\" )
        "))

; implementation of fxzero?
(define-primitive (fxzero? arg)
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

; implementation of null?
(define-primitive (null? arg)
  (emit-expr arg)
  (emit "$P0 = val_x")
  (emit "
        $P3 = new 'PAST::Op'
        $P3.init( $P0, 'pasttype' => 'inline', 'inline' => \"new %r, 'EclectusBoolean'\\n isa $I1, %0, 'EclectusEmptyList'\\n %r = $I1\" )
        val_x = new 'PAST::Op'
        val_x.init( $P3, val_true, val_false, 'pasttype' => 'if' )
        "))

; implementation of fixnum?
(define-primitive (fixnum? arg)
  (emit-expr arg)
  (emit "$P0 = val_x")
  (emit "
        $P3 = new 'PAST::Op'
        $P3.init( $P0, 'pasttype' => 'inline', 'inline' => \"new %r, 'EclectusBoolean'\\n isa $I1, %0, 'EclectusFixnum'\\n %r = $I1\" )
        val_x = new 'PAST::Op'
        val_x.init( $P3, val_true, val_false, 'pasttype' => 'if' )
        "))

; implementation of boolean?
(define-primitive (boolean? arg)
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
(define-primitive (not? arg)
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
(define-primitive (char? arg)
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
  (emit ".local pmc val_true, val_false, val_x")
  (emit-immediate #t)
  (emit "val_true = val_x")
  (emit-immediate #f)
  (emit "val_false = val_x")
)

(define (emit-function-footer)
  (emit "
          .return( val_x )
        .end
        "))

(define (emit-primcall expr)
  (let ([prim (car expr)] [args (cdr expr)])
    (apply (primitive-emitter prim) args)))

(define (emit-immediate expr)
  (emit (immediate-rep expr)))

(define (emit-if expr)
  (emit-expr (if-test expr))
  (emit "$P0 = val_x")
  (emit-expr (if-conseq expr))
  (emit "$P1 = val_x")
  (emit-expr (if-altern expr))
  (emit "$P2 = val_x")
  (emit "
        val_x = new 'PAST::Op'
        val_x.init( $P0, $P1, $P2, 'pasttype' => 'if'  )
        "))
 
; emir PIR for an expression
(define (emit-expr expr)
  ; (display "# ")(write expr) (newline)
  (cond
    [(immediate? expr) (emit-immediate expr)]
    [(if? expr)        (emit-if expr)]
    [(primcall? expr)  (emit-primcall expr)])) 

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
