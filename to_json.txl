% Andrew Fryer, 2023

% Note that the input contains no double quotes, so we can insert them wherever we like in the output to make things clear for Pyhton.

define program
      [Decl*]
    | [Json]
end define

define Json
    '{
        ' " [id] ' " %[KeyValPair,]
    '}
end define

define KeyValPair
    '" [Caller] '" ': '[
        [QuotedCallee,]
    ']
end define

define QuotedCallee
    '" [Callee] '"
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

function main
    replace [program]
        ds [Decl*]
    construct key_val_pairs [KeyValPair,]
        _ %[append_key_val_pair each ds]
    by
        '{
            ' " 'asdf ' "
        '}
end function
