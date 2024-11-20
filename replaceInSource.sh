##we are sh as of writing this but explicitly asking for that is asking for trouble
shopt -s globstar ##yeah i know but better than gnu find dependency

##TO-DO
#bad dry flag debug info please correct for if script actualy has things to be replaced
##	-> before showing replacement idealy for each instance too grep or sum shit


##VARIABLES
dryFlag=false
verboseFlag=false

##FUNCTIONS
helpText () {
echo "Usage: ./findAndReplaceInSource.sh FINDSTRING REPLACESTRING
"
exit
}

verbose () {
if [ "$verboseFlag" = "true" ]; then
	echo "$1"
fi
}

##RUNTIME
if [ -z "$1" ]; then
	helpText
fi
findString=$1
if [ "$2" != "" ]; then	##gotta allow replace with empty
	if [ -z "$2" ]; then
		helpText
	fi
fi
replaceString=$2

thisFolder="${PWD}"
verbose "working in: $thisFolder"

##find ./ -type f -exec sed -i "s/$1/$2/g" {} \;	##no need for gnu find dependancy
scripts=("$thisFolder"/**/*.lua)
for script in "${scripts[@]}"; do
	contents="$(cat $script)"
	if [ "$dryFlag" = "false" ]; then
		##"${contents//findString/replaceString}" | tee "$script"
		##echo "${contents//findString/replaceString}" > "$script"	##attempts to avoid sed dependency
		sed -i "s/$findString/$replaceString/g" "$script"

	fi
	if [ "$dryFlag" = "true" ]; then
		echo "script: $script"
		##echo $grep
		echo "	$findString -> $replaceString"
		verbose "contents:"$'\n'"$contents"
	fi

done
##{$contents//$1/$2} for sustitution, its a substitute expression read sh docs
##sh docs: https://pubs.opengroup.org/onlinepubs/9699919799/utilities/V3_chap02.html
##might be able to be made cleaner using grep, maybe the output of the findInSource idk