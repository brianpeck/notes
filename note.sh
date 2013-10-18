### Note taking
export NOTES_DIR=~/Dropbox/notes
# Create/edit notes
n() {
	$EDITOR $NOTES_DIR/"$*".md
}

# Edit file given index to last query
nne() {
	$EDITOR $NOTES_DIR/`awk "NR==$1" $NOTES_DIR/files.txt`
}

# Move (rename) a note
nmv() {
	mv $NOTES_DIR/$1.md $NOTES_DIR/$2.md
	mv $NOTES_DIR/$1.html $NOTES_DIR/$2.html &> \dev\null
}

# View note given name
nv() {
	markdown $NOTES_DIR/$*.md | lynx -stdin
}

# View note given index to last query
nnv() {
	markdown $NOTES_DIR/`awk "NR==$1" $NOTES_DIR/files.txt` | lynx -stdin
}

# Delete note given index to last query
nnd() {
	rm $NOTES_DIR/`awk "NR==$1" $NOTES_DIR/files.txt` 
}

# Add tags to a note given index to last query
nnat() {
	file=$NOTES_DIR/`awk "NR==$1" $NOTES_DIR/files.txt`
	sed -i "/Tags/ s/$/ #$2/" $file	
}

# Remove tags from a note given index to last query
nnrt() {
	file=$NOTES_DIR/`awk "NR==$1" $NOTES_DIR/files.txt`
	sed -i "/Tags/ s/#$2 \?//" $file
}

# Search for a tag, display files
nft() {
	export NOTES_PWD=`pwd`
	und=`tput smul`
	nound=`tput rmul`
	cd $NOTES_DIR/
	grep -l "#$*" `ls -t *.md` > files.txt
	let i=1
	echo ""
	printf "%2s %-13.13s %-39.39s %-44.44s %-19.19s %s\n" \
		"${und}ID${nound}" "${und}File" "${nound} ${und}Title" "${nound} ${und}Tags" "${nound} ${und}Date" "${nound}" 
	echo -en '\e[0;31m'
	for f in `cat files.txt`
	do
		if [ $(( $i % 2 )) -eq 0 ]
		then
			echo -en '\e[48;5;0m'
		fi
		f2=${f%.*}
		title=`head -q -n 1 $f | cut -d"#" -f2- | sed 's/^ *//g'`
		tags=`grep Tags $f | cut -d"#" -f2- --output-delimiter=""`
		date=`stat -c %y $f | cut -d" " -f1`
		printf "%2d %-10.10s %-30.30s %-35.35s %-10.10s" \
			$i $f2 "$title" "$tags" "$date"
		let "i=$i+1"
		echo -e '\e[0;31m'
	done
	printf "\033[0m "
	echo ""
	cd $NOTES_PWD
}

# Generate all files (or subset), including an index
ng() {
	export NOTES_PWD=`pwd`
	cd $NOTES_DIR/
	if [ -z $* ]; then
		ls *.md > files.txt
	else
		grep -l "#$*" `ls -t *.md` > files.txt
	fi
	echo "<html><head><title>Index</title></head><body><table>" > $NOTES_DIR/html/index.html
	echo "<tr><th>Name</th><th>Title</th><th>Tags</th></tr>" >> $NOTES_DIR/html/index.html
	for f in `cat files.txt`
	do
		f2=${f%.*}
		title=`head -q -n 1 $f | cut -d"#" -f2- | sed 's/^ *//g'`
		tags=`grep Tags $f | cut -d"#" -f2- --output-delimiter=""`
		if [ $f -nt html/$f2.html ]; then 
			markdown $f > html/$f2.html
		fi
		echo "<tr><td><a href=$f2.html>$f2</a></td><td>$title</td><td>$tags</td></tr>" >> $NOTES_DIR/html/index.html	
	done
	echo "</table></body></html>" >> $NOTES_DIR/html/index.html
	lynx $NOTES_DIR/html/index.html
	cd $NOTES_PWD
}

# Create new meeting note with current date in name and title.
# Usage: nm <meeting>
nm () {
	file=$NOTES_DIR/${1,,}$(date +%Y%m%d).md
	if [ ! -f $file ]; then
		echo "# $1 Meeting Notes - `date +%Y-%m-%d`" > $file
		echo "" >> $file
		echo "*Tags:* #Meeting #$1" >> $file
		echo "" >> $file
	fi
	$EDITOR $file
}

nls () {
	tree -CR --noreport $NOTES_DIR -P *.md | awk '{ if ((NR > 1) gsub(/.md/,"")); \
	if (NF==1) print $1; else if (NF==2) print $2; else if (NF==3) printf "  %s\n", $3 }' ;
}


# Creates or adds to a log
# Usage: nlog <name> <item>
nlog () {
	file=$NOTES_DIR/${1,,}.md
	if [ ! -f $file ]; then
		echo "# Log - $1" > $file
		echo "" >> $file
		echo "*Tags:* #Log #$1" >> $file
		echo "" >> $file
	fi
	echo -n $(date +%Y%m%d)": " >> $file
	echo $* | cut -d' ' -f2- >> $file
	echo "" >> $file
}

