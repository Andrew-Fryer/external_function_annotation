# this assumes you have txl installed and on your path

# increase stack limit
ulimit -s hard

# set to maximum memory size (4000M)
(cat std_calls.txt; txl -s 4000M ./all_calls.txt simplify_types.txl) > all_calls_cleaned.txt
