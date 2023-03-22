% Andrew Fryer, 2023

include "./Rust/rust.grm"

define Fact
    [id] '-> [id]
end define

redefine program
    ...
    | [repeat Fact]
end redefine

redefine asdf % maybe FunctionCall
    ...
    | [Fact]
end redefine

rule findFacts
    asdf
end rule

extractFacts
    % use the `extract` keyword
end function/rule

function main
    replace [program]
        p [program]
    by
        p [findFacts] [extractFacts]
end function
