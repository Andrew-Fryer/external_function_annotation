import sys


input_str = '''0 : 36 ~ andrew_fuzz [c4b5] : : core : : bit_array : : {impl # 0} : : new - > std : : rc : : Rc : : < std : : cell : : RefCell < std : : vec : : Vec < u8 > > > : : new;
0 : 36 ~ andrew_fuzz [c4b5] : : core : : bit_array : : {impl # 0} : : new - > std : : cell : : RefCell : : < std : : vec : : Vec < u8 > > : : new;
0 : 36 ~ andrew_fuzz [c4b5] : : core : : bit_array : : {impl # 0} : : new - > std : : vec : : Vec : : < u8 > : : len;
0 : 36 ~ andrew_fuzz [c4b5] : : core : : bit_array : : {impl # 0} : : new - > core : : panicking : : panic;
0 : 36 ~ andrew_fuzz [c4b5] : : core : : bit_array : : {impl # 0} : : new - > std : : vec : : Vec : : < u8 > : : len;
0 : 36 ~ andrew_fuzz [c4b5] : : core : : bit_array : : {impl # 0} : : new - > < std : : vec : : Vec < u8 > as std : : ops : : IndexMut < usize > > : : index_mut;
0 : 36 ~ andrew_fuzz [c4b5] : : core : : bit_array : : {impl # 0} : : new - > < std : : vec : : Vec < u8 > as std : : ops : : IndexMut < usize > > : : index_mut;
0 : 36 ~ andrew_fuzz [c4b5] : : core : : bit_array : : {impl # 0} : : new - > std : : vec : : Vec : : < u8 > : : len;'''

relation = {}

buffer = ""
for line in input_str.split('\n'): #sys.stdin:
    if len(line) == 0:
        continue
    
    line = line.replace(" ", "")
    
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
