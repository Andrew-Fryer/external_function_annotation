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
    replace * [Item]
        'use root_use_tree [UseTree] ';
    deconstruct root_use_tree
        outer_simple_path [SimplePath] ':: '{ inner_simple_path [SimplePath] ', use_tree2 [UseTree] _ [', ?] '}
    deconstruct outer_simple_path
        outer_colons [':: ?] outer_sps [SimplePathSegment] outer_ccspss[COLON_COLON_SimplePathSegment*]
    deconstruct inner_simple_path
        inner_sps [SimplePathSegment] inner_ccspss[COLON_COLON_SimplePathSegment*]
    construct _ [UseTree]
        root_use_tree [print]
    construct new_simple_path_ccsps [COLON_COLON_SimplePathSegment*]
        ':: inner_sps
    construct new_simple_path_ccspss [COLON_COLON_SimplePathSegment*]
        %outer_ccspss [. ':: inner_sps] [. inner_ccspss]
        outer_ccspss [. new_simple_path_ccsps] [. inner_ccspss]
    construct result [Item]
        %simple_path ':: '*
        'use outer_colons outer_sps new_simple_path_ccspss ';
        %'use root_use_tree ';
    by
        result
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
