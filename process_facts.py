import json

# https://pypi.org/project/ordered-set/
from ordered_set import OrderedSet

# Read in data
f = open('./json.txt', mode='r')
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

# Attempt to resolve callees to callers
def possible_callers_for_callee(callee):
    callee = callee[:-1] # remove semicolon
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
callee_to_caller = {}
for callee in all_callees:
    for possible_caller in possible_callers_for_callee(callee):
        if possible_caller in internal_fns:
            if callee in callee_to_caller:
                print('found ambiguity between', callee_to_caller[callee], 'and', possible_caller)
            callee_to_caller[callee] = [possible_caller]
    if callee not in callee_to_caller:
        external_fns.add(callee)

# Build the transitive relation from internal functions to external functions
transitive_internal_calls_external = {}
for fn in internal_fns:
    transitive_internal_calls_external[fn] = OrderedSet()
for external_fn in external_fns:
    work = list(called_by[external_fn])
    while len(work) > 0:
        internal_fn = work.pop()
        if external_fn not in transitive_internal_calls_external[internal_fn]:
            transitive_internal_calls_external[internal_fn].add(external_fn)
            if internal_fn in callee_to_caller:
                internal_fn = callee_to_caller.get(internal_fn)
                for fn in called_by[internal_fn]:
                    work.append(fn)

# Print out the results
for fn in transitive_internal_calls_external:
    print(fn + ':')
    for external_fn in transitive_internal_calls_external[fn]:
        print('\t' + external_fn)
print()
