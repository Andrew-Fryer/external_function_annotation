% Andrew Fryer, 2023

include "./Rust/rust.grm"

define QualifierTableEntry
    [stringlit] '-> [stringlit]
end define

define QualifierTable
    [repeat QualifierTableEntry]
end define

function findUses s [SimplePath]
    replace [UseDeclaration]
        ud [UseDeclaration]
    by
        ud
end function

function extractUseDeclarations be [BlockExpression]
    replace [QualifierTable]
        qt [QualifierTable]
%    construct qtes [repeat QualifierTableEntry]
%        qt
%    by
%        qt [. each qtes]
    by
        qt
end function

rule fullyQualify %sp [SimplePath] qt [QualifierTable]
    replace $ [Statements]
        Ss [Statements]
    by
        Ss
end rule

rule expand_uses
    replace $ [UseTree]
        root_use_tree [UseTree]
    %deconstruct root_use_tree
        %simple_path [SimplePath?] ':: '{ use_tree [UseTree] _ [', ?] '}
    construct _ [UseTree]
        root_use_tree [print]
    by
        %simple_path ':: '*
        root_use_tree
end rule

function main
    replace [program]
        p [program]
        % p [fullyQualify "crate" _]
    by
        p [expand_uses]
end function

% Note: the leaves of the tree will be ExternBlock
% program -> Crate -> Item -> VisItem_or_MacroItem -> VisItem -> VisibleItem -> UseDeclaration | Module
