% Andrew Fryer, 2023

include "./call_island.grm"

% Note that the input contains no double quotes, so we can insert them wherever we like in the output to make things clear for Pyhton.

redefine program
      [Decl*]
    | [Json]
end define

define Json
    '{
        [KeyValPair,]
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

function append_callee c [Callee]
    replace [QuotedCallee,]
        existing [QuotedCallee,]
    construct new [QuotedCallee]
        '" c '"
    by
        new [, existing]
        exisitng
end function

function append_key_val_pair d [Decl]
    replace [KeyValPair,]
        existing [KeyValPair,]
    deconstruct d
        'Decl '( caller [Caller] ') '{
            callees [Callee*]
        '}
    construct new_callees [QuotedCallee,]
        _ [append_callee each callees]
    construct new [KeyValPair]
        '" caller '" ': '[
            new_callees
        ']
    by
        new [, existing]
end function

rule main
    replace [program]
        ds [Decl*]
    construct key_val_pairs [KeyValPair,]
        _ [append_key_val_pair each ds]
    by
        '{
            key_val_pairs
        '}
end rule
