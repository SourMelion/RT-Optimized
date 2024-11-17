key=$1
grep --include=\*.{lua,json,cfg} -rn './' -e "$key"