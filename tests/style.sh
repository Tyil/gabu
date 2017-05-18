#! /usr/bin/env sh

for f in src/*.pl
do
	perltidy "$f"
	diff "$f" "$f.tdy"

	if [ $? != 0 ]
	then
		echo "Source not tidy!"
		exit 1
	fi

	rm "$f.tdy"
done

echo "Source code is tidy"

