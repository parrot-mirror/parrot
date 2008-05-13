grammar Pheme::Grammar;

rule TOP { <list>+ }

rule list { '(' [ <special_form> | <application> | <cons> ] ')' }

rule special_form { <special> <list_item>+ }

rule application { <atom> <list_item>+ }

rule cons { <list_item>+ }

# quoted_string has to come first
rule list_item { <quoted_string> | <atom> | <list> | <empty_list> }

token empty_list { <quote>? '()' }

token atom { [ <symbol_tag> | <quote> ]? <-[\ \n\r\(\)]>+ }

token quoted_string { <PGE::Text::bracketed: '"'> }

token quote { \' }

token symbol_tag { '#' }

token ws { [ [ ';' \N+ ]? \s+ ]* }

token special { ('if' | 'cond' | 'define' | 'lambda' | 'quote') }
