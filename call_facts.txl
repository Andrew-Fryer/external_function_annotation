% Andrew Fryer, 2023

include "./call_island.grm"

define program
    [Decl*]
end define

define Decl
    [SPOFF] 'Decl '( [Caller] ') '{ [NL] [IN]
        [Callee*] [EX]
    '} [SPON] [NL]
end redefine

define Callee
    [not_brace_or_parenthesis] '; [NL]
end define

define Caller
    %
end define

% inspiration taken from rust.grm:
define SimplePath
    [id] [COLON_COLON_SimplePathSegment*]
end define
define COLON_COLON_SimplePathSegment
    ':: [id]
end define
%^ inspiration taken from rust.grm

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
        es %[remove_generics]
end function
