import sys


def remove_generics(fn_name):
    while True:
        ind = fn_name.find('<')

def convert_orign_fn_name(fn_name):
    l = fn_name.split('::')
    l.pop(0)
    l = [x for x in l if len(l) > 0 and l[0] != '{']
    return l
    # ind = fn_name.find('~')
    # if ind < 0:
    #     return fn_name
    # ind = fn_name.find('::')
    # assert(ind >= 0)
    # fn_name = fn_name[ind + 2:]

    # ind_opening = fn_name.find('{')
    # ind_closing = fn_name.find('}')
    # if ind_opening >= 0 and ind_closing > ind_opening:
    #     assert(ind_opening > 2 and fn_name[ind_opening - 1] == ':' and fn_name[ind_opening - 2] == ':')
    #     fn_name = fn_name[:ind_opening] + "_" + fn_name[ind_closing + 1:]
    # # else:
    # #     assert(False)
    # return fn_name

def convert_target_fn_name(fn_name):
    i = len(fn_name)
    j = None
    while i >= 2:
        if fn_name[i - 2] == ':' and fn_name[i - 1] == ':':
            if j != None:
                fn_name = fn_name[:i] + '_' + fn_name[j - 2:]
                return fn_name
            else:
                j = i
        i -= 1
    # assert(False)
    return fn_name

called_by_relation = {} # is called by relation
# relation_domain = set()
called_by_relation_range = set()

buffer = ""
for line in open('./all_calls.txt', 'r'): #sys.stdin:
    line = line.replace("\n", "")
    line = line.replace(" ", "")
    if len(line) == 0:
        continue
    
    if line[-1] != ";":
        buffer += line
        continue
    
    line = buffer + line
    buffer = ""

    ind = line.find("-->>")
    if ind < 0:
        raise Exception("couldn't find '-->>' in line")
    
    origin_fn_name = line[:ind]
    target_fn_name = line[ind + 2:-1]

    origin_fn_name_old = origin_fn_name
    target_fn_name_old = target_fn_name

    origin_fn_name = convert_orign_fn_name(origin_fn_name)
    target_fn_name = convert_target_fn_name(target_fn_name)
    
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
                work.append(fn)

# print(called_by_relation)
# print(transitive_call_relation)
for fn in transitive_call_relation:
    print(fn + ':')
    for external_fn in transitive_call_relation[fn]:
        print('\t' + external_fn)
