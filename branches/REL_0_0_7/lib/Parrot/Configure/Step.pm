package Parrot::Configure::Step;

use strict;
use Exporter;
use vars qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

@ISA=qw(Exporter);

@EXPORT=();

@EXPORT_OK=qw(prompt genfile cc_gen cc_build cc_run cc_clean cc_run_capture);

%EXPORT_TAGS=(
	inter => ['prompt'],
	auto  => [qw(cc_gen cc_build cc_run cc_clean cc_run_capture)],
	gen   => ['genfile']
);
	

#Configure::Data->get('key')
#Configure::Data->set('key', 'value')
#Configure::Data->keys()
#Configure::Data->dump()

sub prompt {
	my($message, $value)=@_;

	print("$message [$value] ");

	chomp(my $input=<STDIN>);
	
	while($input =~ s/:add\{([^}]+)\}//) {
		$value .= $1;
	}

	while($input =~ s/:rem\{([^}]+)\}//) {
		$value =~ s/\Q$1\E//;
	}
	
	if($input) {
		$value =  $input;
	}
	
	return $value;
}

sub genfile {
	my($source, $target)=@_;
	
	open IN , "< $source" or die "Can't open $source: $!";
	open OUT, "> $target" or die "Can't open $target: $!";
	
	while(<IN>) {
		s{
                    \$\{(\w+)\}
                }{Configure::Data->get($1)}egx;
		print OUT;
	}
	
	close IN  or die "Can't close $source: $!";
	close OUT or die "Can't close $target: $!";
}

sub cc_gen {
	my($source)=@_;
	
	genfile($source, "test.c");
}

sub cc_build {
	my($cc, $ccflags, $ldout, $o, $ld, $ldflags, $cc_exe_out, $exe, $libs)=
		Configure::Data->get( qw(cc ccflags ld_out o ld ldflags cc_exe_out exe libs) );
	
	system("$cc $ccflags -I./include -c test.c >test.cco 2>&1") and die "C compiler failed (see test.cco)";
	
	system("$ld $ldflags test$o ${cc_exe_out}test$exe $libs >test.ldo 2>&1") and die "Linker failed (see test.ldo)";
}

sub cc_run {
	my $exe=Configure::Data->get('exe');
    if (defined($_[0]) && length($_[0])) {
	    `./test$exe $_[0]`;
    }
    else {
	    `./test$exe`;
    }
}

sub cc_run_capture {
	my $exe=Configure::Data->get('exe');
    if (defined($_[0]) && length($_[0])) {
	    `./test$exe $_[0] 2>&1`;
    }
    else {
	    `./test$exe 2>&1`;
    }
}

sub cc_clean {
	unlink glob "test.*";
}

1;
