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

define Caller
      [number] ': [number] '~ [id] '[ [number] 'f '] [COLON_COLON_SimplePathSegment*] % input
    | [SimplePath] % output
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

%%%



define Callee
    [FullQualifiedCallable] '; [NL]
end define

define FullQualifiedCallable
    [CallableStart] [Callable]
end define

define Callable
      [id]
    %| '[ 'closure [] ']
end define

define CallableStart
      %[TypePrefix?] [CallablePathSegment_COLON_COLON*]
      [CallablePathSegment_COLON_COLON*]
    | '< [FullQualifiedType] 'as [FullQualifiedType] '> '::
end define

define CallablePathSegment_COLON_COLON
    [CallablePathSegment] '::
end define

define CallablePathSegment
      [id]
    | '< [FullQualifiedType] '>
end define

define FullQualifiedType
    [TypePrefix?] [TypePathSegment_COLON_COLON*] [Type]
end define

define TypePrefix
      '&
    | '& 'mut
    | 'dyn
    | 'dyn 'for '< '' [id] '>
end define

define Type
      [id]
    %|
end define

define TypePathSegment_COLON_COLON
    [TypePathSegment] '::
end define

define TypePathSegment
      [id]
    | [id] '< [FullQualifiedTypeOrLifeTime,] '>
end define

define FullQualifiedTypeOrLifeTime
      [FullQualifiedType]
    | '' [id]
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

% Dr. Dean says to use `[not opening_brace] [token]` instead of using keywords. I'm not sure why...
keys
    '{
    '}
    '(
    ')
    '[
    ']
    '<
    '>

    'dyn
    'as
end keys

tokens
    charlit "" % undefines character literals because rust uses a single quote for lifetimes
end tokens

function main
    replace [program]
        es [Decl*]
    by
        es %[clean_caller] [normalize_simple_path_segments] [transform_decl]
end function
