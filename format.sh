##we are sh as of writing this but explicitly asking for that is asking for trouble
shopt -s globstar

echo "if this fails please look in the script for requirements"
##sudo apt install cargo ##debian
cargo install --root . stylua --features lua52

./bin/stylua --respect-ignores --verbose ./**/*.lua
##--respect-ignores to respect ignores in .styluaignore, factorios lua is a bit modified shit happens