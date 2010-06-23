#!./parrot-nqp
# Copyright (C) 2010, Parrot Foundation.
# $Id: Match.nqp 47631 2010-06-15 00:14:01Z tcurtis $

class Tree::Pattern::Match is Capture {
    has $!success;
    has $!ast;
    has $!from;

    method new ($success?, $from?) {
        my $self := Q:PIR {
            $P0 = self.'HOW'()
            $P0 = getattribute $P0, 'parrotclass'
            %r = new $P0
        };
        $self.success($success);
        $self.from($from);
        $self;
    }

    method Bool () {
        ?self;
    }

    method ast () {
        pir::getattribute__PPS(self, '$!ast');
    }

    method from ($from?) {
        my $result;
        if pir::defined__IP($from) {
            pir::setattribute(self, ~'$!from', $from);
        } else {
            $result := pir::getattribute__PPS(self, '$!from');
        }
        $result;
    }

    method success ($success?) {
        my $result;
        if pir::defined__IP($success) {
            pir::setattribute(self, ~'$!success', $success);
        }
        else {
            $result := pir::getattribute__PPS(self, '$!success');
        }
        $result;
    }
}

INIT {
    my $pc :=
      pir::getattribute__PPS(Tree::Pattern::Match.HOW(), "parrotclass");
    $pc.add_vtable_override("get_bool", 
                            method () {
                                ?pir::getattribute__PPS(self,
                                                        '$!success');
                            });

    $pc.add_method("!make",
                   method ($ast) {
                       pir::setattribute(self,  ~'$!ast', $ast);
                   });
}

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
