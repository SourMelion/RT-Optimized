key=$1
grep --include=\*.{cfg,lua} -rn './' -e "$key"