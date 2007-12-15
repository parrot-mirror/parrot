; $Id$

; Generate driver and PAST for Eclectus

; Emit PIR that loads libs
(define (emit-init)
  (emit 
"

# EclectusBoolean is defined here
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

; emit PIR that prints the value returned by scheme_entry()
(define (emit-driver)
  (emit 
"
.sub drive :main

    .local pmc val_ret
    ( val_ret ) = scheme_entry()
    # _dumper( val_ret, 'val_ret' )

    .local pmc var_last
    var_last = new 'PAST::Var'
    var_last.init( 'name' => 'last', 'scope' => 'package', 'lvalue' => 1 )
               
    .local pmc op_bind
    op_bind = new 'PAST::Op'
    op_bind.init( var_last, val_ret, 'pasttype' => 'bind' )
           
    .local pmc op_say
    op_say = new 'PAST::Op'
    op_say.init( op_bind, 'name' => 'say', 'pasttype' => 'call' )

    .local pmc stmts
    stmts = new 'PAST::Stmts'
    stmts.'init'( op_say, 'name'=>'stmts' )

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
  (emit
"
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
"))

; forms represented by a scalar PMC
(define (immediate? expr)
  (or (fixnum? expr)
      (boolean? expr)
      (char? expr)
      (and (list? expr) (= (length expr) 0 ))))

; is expr a primitive?
(define (primitive? x)
  (and (symbol? x) (getprop x '*is-prim*)))

; is expr a call to a primitive? 
(define (primcall? expr)
  (and (pair? expr) (primitive? (car expr))))

(define (immediate-rep x)
  (cond
     [(fixnum? x) (format
"
    val_x = new 'PAST::Val'
    val_x.init( 'value' => ~a, 'returns' => 'Integer' )
" x )]
     [(char? x) (format
"
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
" )]))

; a unary function is a symbol with the properties
; *is-prim*, *arg-count* and *emitter*
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

; add implementation of functions
(define-primitive (fxadd1 arg)
  (emit-expr arg)
  (emit "$P0 = val_x")
  (emit-immediate 1)
  (emit "$P1 = val_x")
  (emit
"
  val_x = new 'PAST::Op'
  val_x.init( $P0, $P1, 'name' => 'infix:+', 'pirop' => 'n_add' )
  #_dumper( val_x, 'val_x' )
"))

; a getter of '*emitter*'
(define (primitive-emitter x)
  (getprop x '*emitter*))

(define (emit-function-header function-name)
  (emit (string-append ".sub " function-name))
  (emit ".local pmc val_x"))

(define (emit-function-footer)
  (emit 
"
  .return( val_x )
.end
"))


(define (emit-primcall expr)
  (let ([prim (car expr)] [args (cdr expr)])
    (apply (primitive-emitter prim) args)))

(define (emit-immediate x)
  (emit (immediate-rep x)))
 
(define (emit-expr expr)
  (cond
    [(immediate? expr) (emit-immediate expr)]
    [(primcall? expr)  (emit-primcall expr)])) 

; the actual compiler
(define (compile-program x)
  (emit-init)
  (emit-driver)
  (emit-builtins)
  (emit-function-header "scheme_entry")
  (emit-expr x) 
  (emit-function-footer))
