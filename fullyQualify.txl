% Andrew Fryer, 2023

include "./Rust/rust.grm"

redefine UseDeclaration
    'use [UseTree,] ';
end redefine

function append_joined_simple_paths outer_simple_path [SimplePath] inner_use_tree [UseTree]
    replace [UseTree,]
        existing [UseTree,]
    construct _ [UseTree]
        inner_use_tree %[debug]
    deconstruct outer_simple_path
        outer_colons [':: ?] outer_sps [SimplePathSegment] outer_ccspss [COLON_COLON_SimplePathSegment*]
    deconstruct inner_use_tree
        inner_sps [SimplePathSegment] inner_ccspss [COLON_COLON_SimplePathSegment*]
    construct new_simple_path_ccsps [COLON_COLON_SimplePathSegment*]
        ':: inner_sps
    construct new_simple_path_ccspss [COLON_COLON_SimplePathSegment*]
        outer_ccspss [. new_simple_path_ccsps] [. inner_ccspss]
    construct new_simple_path [SimplePath]
        outer_colons outer_sps new_simple_path_ccspss
    construct new_use_tree [UseTree,]
        new_simple_path %[print]
    by
        existing [, new_use_tree]
end function

function has_branching
    match * [UseTree,]
        outer_simple_path [SimplePath] ':: '{ inner_use_trees [UseTree,] _ [', ?] '}
    construct violating_use_tree [UseTree]
        outer_simple_path ':: '{ inner_use_trees '}
    construct _ [UseTree]
        violating_use_tree [print]
end function

rule expand_use_trees
    replace [UseTree,]
        outer_simple_path [SimplePath] ':: '{ inner_use_trees [UseTree,] _ [', ?] '}
        ', rest [UseTree,]
    where not
        inner_use_trees [?has_branching]
    by
        _ [append_joined_simple_paths outer_simple_path each inner_use_trees] [, rest]
end rule

function append_use_decl use_tree [UseTree]
    replace [Item*]
        existing [Item*]
    construct new_use_decl [Item*]
        'use use_tree ';
    by
        existing [. new_use_decl]
end function

rule expand_use_decls
    replace $ [Item*]
        'use use_trees [UseTree,] ';
        rest [Item*]
    by
        _ [append_use_decl each use_trees] [. rest]
end rule

function main
    replace [program]
        p [program]
    by
        p [expand_use_trees] [expand_use_decls]
end function

% Note: the leaves of the tree will be ExternBlock
% program -> Crate -> Item -> VisItem_or_MacroItem -> VisItem -> VisibleItem -> UseDeclaration | Module
