% Andrew Fryer, 2023

%include "./call_island.grm"

% Note that the input contains no double quotes, so we can insert them wherever we like in the output to make things clear for Pyhton.

redefine program
    [Decl*]
end define

compounds
    '::
    '->
end compounds

tokens
    charlit "" % undefines character literals because rust uses a single quote for lifetimes
end tokens

redefine Decl
    'Decl '( [Caller] ') '{ [NL] [IN]
        [Callee*] [EX]
    '} [NL]
end redefine

define Caller
      [number] ': [number] '~ [id] '[ [number] [id] '] [COLON_COLON_SimplePathSegment*] % input
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

%%%



define Callee
    [FullQualifiedCallable] '; [NL]
end define

define FullQualifiedCallable
    ['dyn ?] [CallableStart] ':: [CallablePathSegment_COLON_COLON*] [Callable]
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
    | '( [FullQualifiedType,] [', ?] ')
    | '[ 'closure '@  [not_bracket*] ']
end define

define TypePrefix
      '&
    | '& 'mut
    | [DynTypePrefix]
end define

define DynTypePrefix
      'dyn
    | 'dyn 'for '< '' [id] '>
end define

define Type
      [id]
    | [id] '< [FullQualifiedTypeOrLifeTime,] '> % generic
    | 'Fn '( [FullQualifiedType] ') '-> [FullQualifiedType]
    | '[ [FullQualifiedType] '; [number] '] % slice type
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

rule clean_caller
    replace [Caller]
        _ [number] ': _ [number] '~ caller_name [id] '[ _ [number] _ [id] '] path [COLON_COLON_SimplePathSegment*]
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

rule remove_generics_from_types
    replace [Type]
        type_name [id] '< _ [FullQualifiedTypeOrLifeTime,] '>
    by
        type_name
end rule

function append_callable_path_segment type_segment [TypePathSegment_COLON_COLON]
    replace [CallablePathSegment_COLON_COLON*]
        existing [CallablePathSegment_COLON_COLON*]
    deconstruct type_segment
        type_name [id] ':: % warning! I think this will silently skip appending non-matching segments
    construct new [CallablePathSegment_COLON_COLON*]
        type_name '::
    by
        existing [. new]
end function

function is_dyn
    match [TypePrefix]
        _ [DynTypePrefix]
end function

function maybe_dyn_prefix maybe_type_prefix [TypePrefix?]
    replace ['dyn ?]
        _ ['dyn ?]
    deconstruct maybe_type_prefix
        type_prefix [TypePrefix]
    where
        type_prefix [is_dyn]
    by
        'dyn
end function

rule remove_as_type
    replace [FullQualifiedCallable]
        callable_start [CallableStart] ':: callable_path_segments [CallablePathSegment_COLON_COLON*] callable [Callable]
    deconstruct callable_start
        '< full_type [FullQualifiedType] 'as _ [FullQualifiedType] '>
    deconstruct full_type
        type_prefix [TypePrefix?] type_segments [TypePathSegment_COLON_COLON*] type [Type]
    construct opt_dyn_prefix ['dyn ?]
        _ [maybe_dyn_prefix type_prefix]
    deconstruct type
        type_name [id] % this prevents some complex generic stuff from being simplified
    construct path_segment_for_type_name [CallablePathSegment_COLON_COLON*]
        type_name '::
    construct path_segments [CallablePathSegment_COLON_COLON*]
        _ [append_callable_path_segment each type_segments]
        [. path_segment_for_type_name]
    deconstruct path_segments
        first_path_segment [id] ':: cons_path_segments [CallablePathSegment_COLON_COLON*]
    construct new_callable_path_segments [CallablePathSegment_COLON_COLON*]
        cons_path_segments [. callable_path_segments]
    construct result [FullQualifiedCallable]
        %type_segments type ':: callable_path_segment callable
        opt_dyn_prefix first_path_segment ':: new_callable_path_segments callable
    by
        result %[remove_generics_from_types]
end rule

rule remove_generics_from_path
    replace [CallablePathSegment_COLON_COLON*]
        '< _ [Generic] '> ':: remaining [CallablePathSegment_COLON_COLON*]
    by
        remaining
end rule

function remove_last
    replace * [CallablePathSegment_COLON_COLON*] % searching function
        _ [CallablePathSegment_COLON_COLON]
    by
        _
end function

rule get_last
    replace [CallablePathSegment_COLON_COLON*]
        a [CallablePathSegment_COLON_COLON] b [CallablePathSegment_COLON_COLON] remaining [CallablePathSegment_COLON_COLON*]
    by
        b remaining
end rule

rule remove_trailing_generics_from_path
    replace [FullQualifiedCallable]
        %callable_start [CallableStart] ':: segments [CallablePathSegment_COLON_COLON*] last_segment_name [id] ':: '< _ [FullQualifiedType,] '>
        callable_start [CallableStart] ':: segments [CallablePathSegment_COLON_COLON*] '< _ [FullQualifiedType,] '>
    construct all_but_last_segments [CallablePathSegment_COLON_COLON*]
        segments [remove_last]
    construct last_segment_list [CallablePathSegment_COLON_COLON*]
        segments [get_last]
    deconstruct last_segment_list
        last_segment [id] '::
    by
        callable_start ':: all_but_last_segments last_segment
end rule

function main
    replace [program]
        es [Decl*]
    by
        es [clean_caller] [normalize_simple_path_segments] [remove_generics_from_types] [remove_as_type] [remove_generics_from_path] [remove_trailing_generics_from_path]
end function
