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
    [Type] '; [NL]
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
      [number] ': [number] '~ [id] '[ [number] 'f '] [COLON_COLON_SimplePathSegment*] % input
    | [SimplePath] % output
end define

define TypePrefix
      '&
    | '& 'mut
    | 'dyn
    | 'dyn 'for '< '' [id] '>
end define

define TypePath % ':: [id] for easily extracting the method name?
      [TypePrefix?] [id] [COLON_COLON_PathSegment*]
    | '< [Type] 'as [Type] '> [COLON_COLON_PathSegment*]
    | [PathSegment]
end define

define TypeOrLifetime
      [TypePath]
    | '' [id]
end define

define Type
      [TypePath]
    | [TypePath] ':: [Type] % this is hacky :|
    | '[ 'closure [not_brackets*] ']
    | '( [Type,] [',?] ') % tuple type
    | 'Fn '( [Type] ') '-> [Type] % fn type
    | '[ [Type] '; [number] '] % slice type
    | [id] '< [TypeOrLifetime,] '>
end define

define COLON_COLON_PathSegment
    ':: [PathSegment]
end define

define PathSegment
      [id]
    | '< [Generic] '>
    | [Type]
end define

define Generic
      [TypeOrLifetime,]
    | 'impl 'f64 % change to [id] ?
    | 'impl '[ [Type] ']
end define

define not_angle_bracket
    [not '<] [not '>] [wildcard]
end define

% inspiration taken from rust.grm:
define SimplePath
    [id] [COLON_COLON_SimplePathSegment*]
end define
define COLON_COLON_SimplePathSegment
    ':: [SimplePathSegment]
end define
%^ inspiration taken from rust.grm

define SimplePathSegment
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

% this converts things like "{closure # 5}" to "{closure # 0}" or "{impl # 8}" to "{impl # 0}"
rule normalize_simple_path_segments
    replace $ [SimplePathSegment] % this is a one-pass rule
        '{ type [id] '# _ [number] '}
    by
        '{ type '# '0 '}
end rule

rule remove_generics_from_path
    replace [COLON_COLON_PathSegment*]
        ':: '< _ [Generic] '> remaining [COLON_COLON_PathSegment*]
    by
        remaining
end rule

rule remove_generics_from_types
    replace [Type]
        type [Type]
    deconstruct type
        simple_type [id] '< _ [TypeOrLifetime,] '>
    construct _ [Type]
        type [print]
    construct _ [id]
        simple_type [message "success"] [print]
    by
        simple_type
end rule

rule remove_as_type
    replace [TypePath]
        '< pre [TypePrefix?] first [id] next [COLON_COLON_PathSegment*] 'as _ [Type] '> rest [COLON_COLON_PathSegment*]
    construct new_rest [COLON_COLON_PathSegment*]
        next [. rest]
    construct result [Type]
        pre first new_rest [print] [debug]
    by
        result [remove_generics_from_types]
end rule

rule transform_decl
    replace $ [Decl]
        d [Decl]
    by
        d [remove_generics_from_path] [remove_generics_from_types] [remove_as_type] [remove_generics_from_path] [remove_generics_from_types]
end rule

function main
    replace [program]
        es [Decl*]
    by
        es [clean_caller] [normalize_simple_path_segments] [transform_decl]
end function
