#!/bin/sh

print_usage() {
	echo "Usage: $0 <from_img> <to_img>"
}

if [ "z$1" = "z-h" -o "z$1" = "z--help" ]; then
	print_usage
	return 0
fi

if [ -z "$1" -o -z "$2" ]; then
	print_usage
	return 1
fi

if [ ! -f $1 ]; then
	echo "file \"$1\" not exists"
	return 1
elif [ -f $2 ]; then
	echo "file \"$2\" exists"
	return 1
fi

NEWSIZE="$(identify -format "%w %h\n" "$1" | awk '{print "80x" $2-$1+80}')"
convert "$1" -resize "$NEWSIZE" "$2"
