import sys


relation = {}

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
    
    if origin_fn_name not in relation:
        relation[origin_fn_name] = set()
    relation[origin_fn_name].add(target_fn_name)

print(relation)
