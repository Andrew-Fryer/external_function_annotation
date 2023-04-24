% Andrew Fryer, 2023

include "./call_island.grm"

% Note that the input contains no double quotes, so we can insert them wherever we like in the output to make things clear for Pyhton.

redefine program
    [Decl*]
end define

redefine Decl
    'Decl '( [Caller] ') '{ [NL] [IN]
        [Callee*] [EX]
    '} [NL]
end redefine

define Callee
    [not '}] [not_semi_colon*] '; [NL]
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
    ':: [path_segment]
end define
%^ inspiration taken from rust.grm

define path_segment
      [id]
    | '{ [id] '# [number] '}
end define

define impl
    '{ 'impl '# [number] '}
end define

define closure
    '{ 'closure '# [number] '}
end define

define constant
    '{ 'constant '# [number] '}
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

rule clean_caller
    replace [Caller]
        _ [number] ': _ [number] '~ caller_name [id] '[ _ [number] 'f '] path [COLON_COLON_SimplePathSegment*]
    by
        caller_name path
end rule

rule normalize_path_segments
    replace $ [path_segment] % this is a one-pass rule
        '{ type [id] '# _ [number] '}
    by
        '{ type '# '0 '}
end rule

rule remove_generics
    replace [Anything*]
        %'< text [Anything*] '>
    by
        _
end rule

rule transform_decl
    replace $ [Decl]
        d [Decl]
    by
        d %[clean_decl]
end rule

function main
    replace [program]
        es [Decl*]
    by
        es [clean_caller] [normalize_path_segments] %[transform_decl] %[remove_generics]
end function
