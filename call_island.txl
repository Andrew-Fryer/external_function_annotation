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

rule remove_waves
    replace [Element*]
        w [Wave]
        remaining [Element*]
    by
        remaining
end rule

function main
    replace [program]
        p [program]
    %construct all_calls [Land*]
        %_ [^ p]
    by
        %p [reparse all_calls]
        p [remove_waves]
end function
