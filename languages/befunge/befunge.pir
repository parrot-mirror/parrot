# $Id$

.include "debug.pir"
.include "load.pir"

=pod

.include "flow.pasm"
.include "io.pasm"
.include "maths.pasm"
.include "stack.pasm"

=cut

.sub "befunge" :main
    .param pmc argv

    .local int    i, debug
    .local string arg, char, file
    .local pmc    playfield

    print "befunge being ported to a working state...\n"

    # disable buffering on stdout
    #getstdout stdout
    #pioctl I10, P10, 3, 0


    i     = 0
    debug = 0

ARGV_NEXT:
    inc i
    arg  = argv[i]
    char = substr arg, 0, 1
    ne char, "-",  ARGV_DONE
    eq arg,  "-d", ARGV_DEBUG
    goto ARGV_NEXT

ARGV_DEBUG:
    debug_initialize()
    goto ARGV_NEXT

ARGV_DONE:
    file      = argv[i]
    playfield = load(file)

=pod

        set S10, P5[I0]
        save S10
        bsr LOAD
        restore P1              # P1 = the playfield
        new P2, .ResizablePMCArray      # P2 = the stack
        set I0, 0               # I0 = x coord of the PC
        set I1, 0               # I1 = y coord of the PC
        set I2, 1               # I2 = direction of the PC
        set I4, 0               # I4 = flag (1=string-mode,2=bridge,3=end)
        time N0                 # N0 = random seed
        mod N0, N0, .RANDMAX
        set S2, ""              # S2 = user input

=pod

TICK:
        set I20, P1[I1;I0]
        chr S0, I20             # S0 = current instruction
        eq I5, 0, TICK_NODEBUG
        bsr DEBUG_CHECK_BREAKPOINT
TICK_NODEBUG:
        eq S0, "\"", FLOW_TOGGLE_STRING_MODE
        eq I4, 1, IO_PUSH_CHAR
        eq I4, 2, MAIN_TRAMPOLINE
        eq I4, 3, MAIN_END

        # Sole number.
        lt S0, "0", NOT_NUM
        le S0, "9", MATHS_PUSH_NUMBER
NOT_NUM:

        # Direction changing.
        eq S0, "^", FLOW_GO_NORTH
        eq S0, ">", FLOW_GO_EAST
        eq S0, "v", FLOW_GO_SOUTH
        eq S0, "<", FLOW_GO_WEST
        eq S0, "?", FLOW_GO_AWAY

        # Flow control.
        eq S0, "`", FLOW_COMPARE
        eq S0, "_", FLOW_EW_IF
        eq S0, "|", FLOW_NS_IF
        eq S0, "#", FLOW_BRIDGE
        eq S0, "@", FLOW_END

        # Math functions.
        eq S0, "+", MATHS_ADD
        eq S0, "-", MATHS_SUB
        eq S0, "*", MATHS_MUL
        eq S0, "/", MATHS_DIV
        eq S0, "%", MATHS_MOD
        eq S0, "!", MATHS_NOT

        # Stack operations.
        eq S0, ":", STACK_DUP
        eq S0, "$", STACK_POP
        eq S0, "\\", STACK_SWAP

        # I/O operations.
        eq S0, "&", IO_INPUT_INT
        eq S0, "~", IO_INPUT_CHAR
        eq S0, ".", IO_OUTPUT_INT
        eq S0, ",", IO_OUTPUT_CHAR
        eq S0, "g", IO_GET_VALUE
        eq S0, "p", IO_PUT_VALUE

        # Unknow instruction.
        branch MOVE_PC

MAIN_TRAMPOLINE:
        set I4, 0               # no more trampoline
MOVE_PC:
        eq I2, 1, MOVE_EAST
        eq I2, 2, MOVE_SOUTH
        eq I2, 3, MOVE_WEST
        # fallback MOVE_NORTH
MOVE_NORTH:
        dec I1
        mod I1, I1, 25
        branch TICK
MOVE_EAST:
        inc I0
        mod I0, I0, 80
        branch TICK
MOVE_SOUTH:
        inc I1
        mod I1, I1, 25
        branch TICK
MOVE_WEST:
        dec I0
        mod I0, I0, 80
        branch TICK

=cut

MAIN_END:
        end
.end

