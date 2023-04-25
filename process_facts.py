import json


f = open('./json.txt', mode='r')
contents = f.read()
f.close()

contents = contents.replace("\n", "")

obj = json.loads(contents)

callers = set()
calls = {}
all_callees = set()
called_by = {}
def record_caller(caller):
    assert(caller not in calls)
    calls[caller] = set()
    assert(caller not in callers)
    callers.add(caller)
def record_call(caller, callee):
    calls[caller].add(callee)
    all_callees.add(callee)
    if callee not in called_by:
        called_by[callee] = set()
    called_by[callee].add(caller)

for caller in obj:
    callees = obj[caller]
    caller = caller.strip()
    record_caller(caller)
    for c in callees:
        callee = c.strip()
        record_call(caller, callee)

internal_fns = callers
external_fns = all_callees - callers

transitive_internal_calls_external = {}
for fn in internal_fns:
    transitive_internal_calls_external[fn] = set()
for external_fn in external_fns:
    work = list(called_by[external_fn])
    while len(work) > 0:
        internal_fn = work.pop()
        if external_fn not in transitive_internal_calls_external[internal_fn]:
            transitive_internal_calls_external[internal_fn].add(external_fn)
            for fn in called_by.get(internal_fn, []):
                work.append(fn)

# print(calls)
for fn in transitive_internal_calls_external:
    print(fn + ':')
    for external_fn in transitive_internal_calls_external[fn]:
        print('\t' + external_fn)

print('here')
