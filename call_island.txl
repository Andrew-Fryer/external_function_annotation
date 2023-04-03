include "./call_island.grm"

define Table
    [Entry*]
end define

define Entry
    [Func] '-> [Func] ';
end define

define Func
    [Any*]
end define

define Any
      [token]
    | [key]
end define

redefine program
      ...
    | [Table]
end redefine

function is_wave
    match [Element]
        w [Wave]
end function

function extract_land e [Element]
    replace [Element*]
        existing [Element*]
    deconstruct e
        l [Land]
    construct new_e [Element]
        l
    by
        existing [. new_e]
end function

function remove_waves
    replace [Element*]
        first [Element]
        remaining [Element*]
    construct new_remaining [Element*]
        remaining [remove_waves]
    by
        _ [extract_land first] [. new_remaining]
end function

function main
    replace [program]
        ds [Decl*]
    by
        _ [remove_waves each ds????]
end function
