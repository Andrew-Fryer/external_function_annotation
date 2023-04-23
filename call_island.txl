include "./call_island.grm"

redefine Decl
      ...
%               caller_fn            callee_fns
    | [SPOFF] 'Decl '( [IslandGrammar] ') '{ [NL] [IN]
        [Callee*] [EX]
    '} [SPON] [NL]
end redefine

define Callee
    [not_bracket*] '; [NL]
end define

function append_callee c [Call]
    replace [Callee*]
        existing [Callee*]
    deconstruct c
        'Call '{ 'ty ': _ [not_bracket*] '{ callee_name [not_bracket*] '} _ [IslandGrammar] '}
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