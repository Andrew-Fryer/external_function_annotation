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

function append_joined_simple_paths outer_simple_path [SimplePath] inner_simple_path [SimplePath]
    replace [SimplePath*]
        existing [SimplePath*]
    deconstruct outer_simple_path
        outer_colons [':: ?] outer_sps [SimplePathSegment] outer_ccspss[COLON_COLON_SimplePathSegment*]
    deconstruct inner_simple_path
        inner_sps [SimplePathSegment] inner_ccspss[COLON_COLON_SimplePathSegment*]
    construct new_simple_path_ccsps [COLON_COLON_SimplePathSegment*]
        ':: inner_sps
    construct new_simple_path_ccspss [COLON_COLON_SimplePathSegment*]
        %outer_ccspss [. ':: inner_sps] [. inner_ccspss]
        outer_ccspss [. new_simple_path_ccsps] [. inner_ccspss]
    construct new_use_tree [UseTree*]
        outer_colons outer_sps new_simple_path_ccspss
    by
        %items [. new_use_decl]
        existing %[. new_use_tree]
end function

%function append_simple_path use_tree []

function extract_simple_paths use_tree [UseTree]
    replace [SimplePath*]
        existing [SimplePath*]
    deconstruct use_tree
        outer_simple_path [SimplePath] ':: '{ inner_use_trees [UseTree,] '}
    construct inner_simple_paths [SimplePath*]
        _ [extract_simple_paths each inner_use_trees]
    construct outer_simple_paths [SimplePath*]
        outer_simple_path % todo: make n copies here somehow
    by
        existing [append_joined_simple_paths each outer_simple_paths inner_simple_paths]
end function

function append_use_decl use_simple_path [SimplePath]
    replace [Item*]
        existing [Item*]
    construct new_use_decl [Item*]
        'use use_simple_path ';
    by
        existing [. new_use_decl]
end function

rule expand_uses
    replace * [Item*]
        'use root_use_tree [UseTree] ';
        post_items [Item*]
    construct use_simple_paths [SimplePath*]
        _ [extract_simple_paths root_use_tree]
    construct new_use_decls [Item*]
        _ [append_use_decl each use_simple_paths]
    by
        new_use_decls [. post_items]

    %construct result [Item*]
        %_ [append_use_decl each outer_simple_paths inner_simple_paths]
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
