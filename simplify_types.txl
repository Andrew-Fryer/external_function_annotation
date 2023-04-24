% Andrew Fryer, 2023

%include "./call_island.grm"

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
    [CallableStart] ':: [CallablePathSegment_COLON_COLON*] [Callable]
end define

define Callable
      [id]
    | '< [FullQualifiedType,] '>
    | [CallablePathSegment] % or, maybe I should merge Callable and CallablePathSegment
end define

define CallableStart
      %[TypePrefix?] [CallablePathSegment_COLON_COLON*]
      [id]
    | '< [FullQualifiedType] 'as [FullQualifiedType] '>
end define

define CallablePathSegment_COLON_COLON
    [CallablePathSegment] '::
end define

define CallablePathSegment
      [id]
    | '< [Generic] '>
end define

define FullQualifiedType
      [TypePrefix?] [TypePathSegment_COLON_COLON*] [Type]
    | '( [FullQualifiedType,] ')
    | '[ 'closure '@  [not_bracket*] ']
end define

define TypePrefix
      '&
    | '& 'mut
    | 'dyn
    | 'dyn 'for '< '' [id] '>
end define

define Type
      [id]
    | [id] '< [FullQualifiedTypeOrLifeTime,] '>
end define

define TypePathSegment_COLON_COLON
    [TypePathSegment] '::
end define

define TypePathSegment
      [id]
end define

define Generic
      [FullQualifiedTypeOrLifeTime,]
    | 'impl 'f64 % change to [id] ?
    | 'impl '[ [FullQualifiedType] ']
end define

define FullQualifiedTypeOrLifeTime
      [FullQualifiedType]
    | '' [id]
end define




define wildcard
      [token]
    | [key]
end define

define bracket
      '[
    | ']
end define

define not_bracket
    [not bracket] [wildcard]
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
