include "./call_island.grm"

define Table
    [Entry*]
end define

define Entry
    [IslandGrammar] '-->> [not_bracket*] '; [NL]
end define

redefine program
      ...
    | [Table]
end redefine

rule remove_waves
    replace [Element*]
        w [Wave]
        remaining [Element*]
    by
        remaining
end rule

function append_entries decl_name [IslandGrammar] c [Call]
    replace [Entry*]
        existing [Entry*]
    construct dry_decl_name [IslandGrammar]
        decl_name %[remove_waves]
    deconstruct c
        'Call '{ 'ty ': _ [not_bracket*] '{ callee [not_bracket*] '} _ [IslandGrammar] '}
    by
        dry_decl_name '-->> callee ';
        existing
end function

function extract_calls d [Decl]
    replace [Entry*]
        existing [Entry*]
    deconstruct d
        'DefId '( decl_name [IslandGrammar] ') ':
        'Thir '{
            decl_body [IslandGrammar]
        '}
    construct calls [Call*]
        _ [^ decl_body]
    construct existing_and_dummy [Entry*]
        decl_name '-->> ';
        existing
    by
        existing_and_dummy [append_entries decl_name each calls]
end function

function main
    replace [program]
        ds [Decl*]
    construct result [Entry*]
        _ [extract_calls each ds]
    by
        result
end function
