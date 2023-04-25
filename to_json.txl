% Andrew Fryer, 2023

% Note that the input contains no double quotes, so we can insert them wherever we like in the output to make things clear for Pyhton.

compounds
    '::
    '->
end compounds

define program
      [Decl*]
    | [Json]
end define

define DoubleQuote
    ' "
end define

define Json
    '{ [NL] [IN]
        [KeyValPair,] [EX]
    '} [NL]
end define

define KeyValPair
    [DoubleQuote] [Caller] [DoubleQuote] ': '[ [NL] [IN]
        [QuotedCallee,] [EX]
    '] [NL]
end define

define QuotedCallee
    [DoubleQuote] [Callee] [DoubleQuote]
end define

define Decl
    'Decl '( [Caller] ') '{ [NL] [IN]
        [Callee*] [EX]
    '} [NL]
end define

define Callee
    [not_semi_colon*] '; [NL]
end define

define not_semi_colon
    [not ';] [wildcard]
end define

define wildcard
      [token]
    | [key]
end define

define not_brackets
    [not '[] [not ']] [wildcard]
end define

define not_parenthesis
    [not '(] [not ')] [wildcard]
end define

define Caller
    [not_parenthesis*]
end define

tokens
    charlit "" % undefines character literals because rust uses a single quote for lifetimes
    stringlit ""
end tokens

function append_callee callee [Callee]
    replace [QuotedCallee,]
        existing [QuotedCallee,]
    construct new [QuotedCallee,]
        '" callee '"
    by
        new [, existing]
end function

function append_key_val_pair d [Decl]
    replace [KeyValPair,]
        existing [KeyValPair,]
    deconstruct d
        'Decl '( caller [Caller] ') '{
            callees [Callee*]
        '}
    construct new_callees [QuotedCallee,]
        _ [append_callee each callees]
    construct new [KeyValPair,]
        '" caller '" ': '[
            new_callees
        ']
    by
        new [, existing]
end function

function main
    replace [program]
        ds [Decl*]
    construct key_val_pairs [KeyValPair,]
        _ [append_key_val_pair each ds]
    by
        '{
            key_val_pairs
        '}
end function
