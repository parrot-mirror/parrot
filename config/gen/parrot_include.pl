package Configure::Step;

use strict;
use vars qw($description @args);
use Parrot::Configure::Step ':gen';

$description="Generating runtime/parrot/include ... ";

my @files = qw(
    include/parrot/chartype.h
    include/parrot/core_pmcs.h
    include/parrot/datatypes.h
    include/parrot/encoding.h
    include/parrot/enums.h
    include/parrot/exceptions.h
    include/parrot/interpreter.h
    include/parrot/io.h
    include/parrot/longopt.h
    include/parrot/resources.h
    include/parrot/string.h
    include/parrot/warnings.h
    classes/timer.pmc
);
my $destdir = 'runtime/parrot/include';

@args=();

sub runstep {
    my @generated = ();
    for my $f (@files) {
	my $in_def = ''; # in #define='def', in enum='enum'
	my ($inc, $prefix, $last_val, $subst, %values);
	open F, "<$f" or die "Can't open $f\n";
	while (<F>) {
	    if (m!
	        &gen_from_(enum|def)\((.*?)\)
		(\s+prefix\((\w+)\))?
		(\s+subst\((s/.*?/.*?/\w*)\))?
		!x
	    ) {
		$inc = $2;
		print "$2 ";
		$prefix = ($4 || '');
		$subst = ($6 || '');
		$in_def = $1;
		$last_val = -1;
		%values = ();
		open INC, ">$inc.tmp" or die "Can't write $inc.tmp";
		print INC <<"EOF";
# DO NOT EDIT THIS FILE.
#
# This file is generated automatically from
# $f by config/gen/parrot_include.pl
#
# Any changes made here will be lost.
#
EOF
		next;
	    }
	    if (/&end_gen/) {
		close INC;
		move_if_diff("$inc.tmp", "$destdir/$inc");
		push(@generated, "$destdir/$inc");
		$in_def = '';
		next;
	    }
	    if ($in_def eq 'def') {
		if (/#define\s+(\w+)\s+(-?\w+)/) {
		    local $_ = "$prefix$1\t$2";
		    eval $subst if ($subst ne '');
		    print INC ".constant $_\n";
		}
	    }
	    elsif ($in_def eq 'enum') {
		if (/(\w+)\s+=\s+(-?\w+)/) {
		    local $_;
		    if (defined($values{$2})) {
			$_ = "$prefix$1\t" . $values{$2};
			$last_val = $values{$2};
		    }
		    else {
			$_ = "$prefix$1\t$2";
			$last_val = $2;
		    }
		    $values{$1} = $2;
		    eval $subst if ($subst ne '');
		    print INC ".constant $_\n";
		}
		elsif (/^\s+(\w+)\s*(?!=)/) {
		    $last_val++;
		    $values{$1} = $last_val;
		    local $_ = "$prefix$1\t$last_val";
		    eval $subst if ($subst ne '');
		    print INC ".constant $_\n";
		}
	    }

	}
	if ($in_def ne '') {
	    die "Missing '&end_gen' in $f\n";
	}
	close(F);
    }
    Configure::Data->set(
	gen_pasm_includes => join("\t\\\n\t", @generated)
    );
}

1;
