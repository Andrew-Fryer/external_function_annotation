# this assumes you have txl installed and on your path

# increase stack limit
ulimit -s hard

# set to maximum memory size (4000M)
txl -s 4000M ./thir-flat.txt isolate_calls.txl > all_calls.txt
