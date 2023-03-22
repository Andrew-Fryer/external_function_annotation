% Andrew Fryer, 2023

include "Rust/rust.grm"

rule findModExternal %File [stringlit]
    replace $ [Module]
        m [Module]
    deconstruct m
        'mod id [IDENTIFIER] ';
   %construct P1 [IDENTIFIER]
       %id [print]
       %id [write File]
    import Mods [repeat IDENTIFIER]
    export Mods [repeat IDENTIFIER]
        Mods [. id] [print]
    by
        m
end rule

function main
    replace [program]
        p [program]
    export Mods [repeat IDENTIFIER]
        _
    construct _ [program]
        p [findModExternal]
    import Mods [repeat IDENTIFIER]
    construct _ [repeat IDENTIFIER]
        Mods [write "mods_found.txt"]
    by
        %p [findModExternal "mods_found.txt"]
        %p [findModExternal]
        p
end function
