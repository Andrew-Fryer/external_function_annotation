# run this script from its directory with the root of your rust project as its argument
rust_project_dir="${1}"

# this assumes you have rustup and txl installed and on your path

./stage1.sh "${rust_project_dir}"
./stage2.sh
./stage3.sh
./stage4.sh
./stage5.sh
