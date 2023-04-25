# run this script from its directory with the root of your rust project as its argument
rust_project_dir="${1}"

script_dir=$(pwd)
output_file="${script_dir}/thir-flat.txt"

pushd "${rust_project_dir}"

# this assumes you have rustup installed and on your path
rustup toolchain install nightly

# use rust nightly
rustup override set nightly

# extract thir from your project
cargo rustc -- -Z unpretty=thir-flat >> "${output_file}"

popd
