import sys
import json

# https://pypi.org/project/ordered-set/
from ordered_set import OrderedSet

# Read in data
# f = open('./json.txt', mode='r')
f = sys.stdin
contents = f.read()
f.close()

contents = contents.replace("\n", "")

obj = json.loads(contents)

# Get data into an efficient data structure
callers = OrderedSet()
calls = {}
all_callees = OrderedSet()
called_by = {}
def record_caller(caller):
    assert(caller not in calls)
    calls[caller] = OrderedSet()
    assert(caller not in callers)
    callers.add(caller)
def record_call(caller, callee):
    calls[caller].add(callee)
    all_callees.add(callee)
    if callee not in called_by:
        called_by[callee] = OrderedSet()
    called_by[callee].add(caller)

for caller in obj:
    callees = obj[caller]
    caller = caller.strip()
    record_caller(caller)
    for c in callees:
        callee = c.strip()
        record_call(caller, callee)

name_to_caller = {}
for c in callers:
    l = c.split('::')
    name = l[-1]
    if name not in name_to_caller:
        name_to_caller[name] = OrderedSet()
    name_to_caller[name].add(c)

# Attempt to resolve callees to callers
def possible_callers_for_callee(callee):
    callee = callee[:-1] # remove semicolon

    if callee[:3] == 'dyn':
        # this is a special case where we know that the call is a dynamic dispatch
        l = callee.split('::')
        name = l[-1]
        yield from name_to_caller.get(name, [])
        return

    yield callee # for things in libraies such as std

    callee = "andrew_fuzz :: " + callee

    yield callee

    l = callee.split('::')
    if len(l) >= 2:
        l[-2] = ' {impl # 0} '
        s = '::'.join(l)
        yield s
    yield 
internal_fns = callers
external_fns = OrderedSet()
callee_to_possible_callers = {}
for callee in all_callees:
    for possible_caller in possible_callers_for_callee(callee):
        if possible_caller in internal_fns:
            if callee in callee_to_possible_callers:
                # with dynamic dispatch, we find ambiguities regularly
                # print('found ambiguity between', callee_to_caller[callee], 'and', possible_caller)
                callee_to_possible_callers[callee].add(possible_caller)
            callee_to_possible_callers[callee] = OrderedSet([possible_caller])
    if callee not in callee_to_possible_callers:
        external_fns.add(callee)
    
caller_name_to_callee_names = {}
for callee in callee_to_possible_callers:
    for caller in callee_to_possible_callers[callee]:
        if caller not in caller_name_to_callee_names:
            caller_name_to_callee_names[caller] = OrderedSet()
        caller_name_to_callee_names[caller].add(callee)

# Build the transitive relation from internal functions to external functions
transitive_internal_calls_external = {}
for fn in internal_fns:
    transitive_internal_calls_external[fn] = OrderedSet()
for external_fn in external_fns:
    work = list(called_by[external_fn]) # note that work contains caller names (as opposed to callee names)
    while len(work) > 0:
        internal_fn = work.pop()
        if external_fn not in transitive_internal_calls_external[internal_fn]: # this takes care of duplicate calls and direct and indirect recursion
            transitive_internal_calls_external[internal_fn].add(external_fn)
            for callee in caller_name_to_callee_names.get(internal_fn, []):
                for fn in called_by[callee]:
                    work.append(fn)

# Print out the results
for fn in transitive_internal_calls_external:
    print(fn + ':')
    for external_fn in transitive_internal_calls_external[fn]:
        print('\t' + external_fn)
print()
