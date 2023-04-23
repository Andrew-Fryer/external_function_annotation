% Andrew Fryer, 2023

define program
    [Table]
end define

% Dr. Dean says to use `[not opening_brace] [token]` instead of using keywords. I'm not sure why...
keys
    '{
    '}
    '(
    ')
    '[
    ']
    'Call
    '<
    '>
    'dyn
end keys

tokens
    charlit "" % undefines character literals because rust uses a single quote for lifetimes
end tokens

define Table
    [Entry*]
end define

define Entry
    [Anything*] '-->> [Anything*] '; [NL]
end define

define Anything
      [not '-] [token]
    | [not '<] [not '>] [key]
    | '->
end define

rule remove_generics
    replace [Anything*]
        '< text [Anything*] '>
    by
        _
end rule

function main
    replace [program]
        es [Entry*]
    by
        es [remove_generics]
end function
