import sys


called_by_relation = {} # is called by relation
# relation_domain = set()
called_by_relation_range = set()

buffer = ""
for line in sys.stdin:
    line = line.replace("\n", "")
    line = line.replace(" ", "")
    if len(line) == 0:
        continue
    
    if line[-1] != ";":
        buffer += line
        continue
    
    line = buffer + line
    buffer = ""

    ind = line.find("->")
    if ind < 0:
        raise Exception("couldn't find '->' in line")
    
    origin_fn_name = line[:ind]
    target_fn_name = line[ind + 2:-1]
    
    if target_fn_name not in called_by_relation:
        called_by_relation[target_fn_name] = set()
    called_by_relation[target_fn_name].add(origin_fn_name)
    called_by_relation_range.add(origin_fn_name)

internal_fns = called_by_relation_range
external_fns = set(called_by_relation.keys()) - internal_fns

print(external_fns)
print(internal_fns)

transitive_call_relation = {}
for fn in internal_fns:
    transitive_call_relation[fn] = set()
for external_fn in external_fns:
    work = list(called_by_relation[external_fn])
    while len(work) > 0:
        internal_fn = work.pop()
        if external_fn not in transitive_call_relation[internal_fn]:
            transitive_call_relation[internal_fn].add(external_fn)
            for fn in called_by_relation.get(internal_fn, []):
                work.push(fn)

# print(called_by_relation)
# print(transitive_call_relation)
for fn in transitive_call_relation:
    print(fn + ':')
    for external_fn in transitive_call_relation[fn]:
        print('\t' + external_fn)
