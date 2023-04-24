% Andrew Fryer, 2023

include "./call_island.grm"

% Note that the input contains no double quotes, so we can insert them wherever we like in the output to make things clear for Pyhton.

redefine program
    [Decl*]
end define

redefine Decl
    [SPOFF] 'Decl '( [Caller] ') '{ [NL] [IN]
        [Callee*] [EX]
    '} [SPON] [NL]
end redefine

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

define Caller
      [number] ': [number] '~ [id] '[ [number] 'f '] [COLON_COLON_SimplePathSegment*] % input
    | [SimplePath] % output
end define

% inspiration taken from rust.grm:
define SimplePath
    [id] [COLON_COLON_SimplePathSegment*]
end define
define COLON_COLON_SimplePathSegment
    ':: [impl_or_id]
end define
%^ inspiration taken from rust.grm

define impl_or_id
      [id]
    | '{ 'impl '# [number] '}
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

define Anything
      [not '-] [token]
    | [not '<] [not '>] [key]
    | '->
end define

function clean_caller
    replace [Caller]
        _ [number] ': _ [number] '~ caller_name [id] '[ _ [number] 'f '] path [COLON_COLON_SimplePathSegment*]
    by
        caller_name path
end function

rule remove_generics
    replace [Anything*]
        %'< text [Anything*] '>
    by
        _
end rule

function main
    replace [program]
        es [Decl*]
    by
        es %[remove_generics]
end function
