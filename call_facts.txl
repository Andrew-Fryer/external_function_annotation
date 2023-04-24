% Andrew Fryer, 2023

include "./Rust/rust.grm"
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
    [PathExpression] '; [NL]
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

define Caller
      [integer_number] ': [integer_number] '~ [id] '[ [integer_number] 'f '] [COLON_COLON_SimplePathSegment_*] % input
    | [SimplePath_] % output
end define

%%

define not_angle_bracket
    [not '<] [not '>] [wildcard]
end define

% inspiration taken from rust.grm:
define SimplePath_
    [id] [COLON_COLON_SimplePathSegment_*]
end define
define COLON_COLON_SimplePathSegment_
    ':: [SimplePathSegment_]
end define
%^ inspiration taken from rust.grm

define SimplePathSegment_
      [id]
    | '{ [id] '# [integer_number] '}
end define

define impl
    '{ 'impl '# [integer_number] '}
end define

define closure
    '{ 'closure '# [integer_number] '}
end define

define constant
    '{ 'constant '# [integer_number] '}
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
        _ [integer_number] ': _ [integer_number] '~ caller_name [id] '[ _ [integer_number] 'f '] path [COLON_COLON_SimplePathSegment_*]
    by
        caller_name path
end rule

% this converts things like "{closure # 5}" to "{closure # 0}" or "{impl # 8}" to "{impl # 0}"
rule normalize_simple_path_segments
    replace $ [SimplePathSegment_] % this is a one-pass rule
        '{ type [id] '# _ [integer_number] '}
    by
        type
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
        es [clean_caller] [normalize_simple_path_segments] %[transform_decl] %[remove_generics]
end function
