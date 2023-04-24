include "./call_island.grm"

redefine Decl
      ...
    | 'Decl '( [IslandGrammar] ') '{ [NL] [IN] % caller_fn
        [Callee*] [EX] % callee_fns
    '} [NL]
end redefine

define Callee
    [not_brace*] '; [NL]
end define

function append_callee c [Call]
    replace [Callee*]
        existing [Callee*]
    deconstruct c
        'Call '{ 'ty ': _ [not_brace*] '{ callee_name [not_brace*] '} _ [IslandGrammar] '}
    construct callee [Callee]
        callee_name ';
    by
        callee
        existing
end function

rule main
    replace [Decl]
        'DefId '( decl_name [IslandGrammar] ') ':
        'Thir '{
            decl_body [IslandGrammar]
        '}
    construct calls [Call*]
        _ [^ decl_body]
    construct callees [Callee*]
        _ [append_callee each calls]
    by
        'Decl '( decl_name ') '{
            callees
        '}
end rule