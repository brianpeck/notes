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
	# Calculate column widths
	col=$(tput cols)
	let title_col=(col-28)/2
	tags_col=$title_col
	if [ $title_col -gt 40 ]; then
		title_col=40
		tags_col=40
	fi
		
	let i=1
	echo ""
	printf "%2s %-15.15s %-$(($title_col+9)).$(($title_col+9))s %-$(($tags_col+9)).$(($tags_col+9))s %-19.19s %s\n" \
		"${und}ID${nound}" "${und}File" "${nound} ${und}Title" "${nound} ${und}Tags" "${nound} ${und}Date" "${nound}" 
	echo -en '\e[0;31m'
	for f in `cat files.txt`
	do
		f2=${f%.*}
		title=`head -q -n 1 $f | cut -d"#" -f2- | sed 's/^ *//g'`
		tags=`grep Tags $f | head -1 | cut -d"#" -f2- --output-delimiter=""`
		date=`stat -c %y $f | cut -d" " -f1`
		ip=$i
		# loop to make sure we fit all tags on their own lines
		while [ `echo $tags | wc -m` -gt $tags_col ];
		do
			tags_cur=`echo $tags | cut -d' ' -f1`
			j=1
			# loop to get exactly as many tags as will fit on the line
			while [ `echo $tags | cut -d' ' -f1-$j | wc -m` -lt $tags_col ];
			do
				tags_cur=`echo $tags | cut -d' ' -f1-$j`
				let j=j+1
			done
			# change color for alternate lines
			if [ $(( $i % 2 )) -eq 0 ]
			then
				echo -en '\e[48;5;0m'
			fi
			# print formatted line
			printf "%-2.2s %-12.12s %-$(($title_col)).$(($title_col))s %-$(($tags_col)).$(($tags_col))s %-10.10s" \
				"$ip" "$f2" "$title" "$tags_cur" "$date"
			echo -e '\e[0;31m'
			# remove stuff that has been printed
			tags=`echo $tags | cut -d' ' -f$j-`
			f2=" "
			date=" "
			title=" "
			ip=" "
		done
		# change color for alternate lines
		if [ $(( $i % 2 )) -eq 0 ]
		then
			echo -en '\e[48;5;0m'
		fi
		# print formatted line
		printf "%-2.2s %-12.12s %-$(($title_col)).$(($title_col))s %-$(($tags_col)).$(($tags_col))s %-10.10s" \
			"$ip" "$f2" "$title" "$tags" "$date"
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
	if [ ! -d "html" ]; then
		mkdir html
	fi
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
		tags=`grep Tags $f | head -1 | cut -d"#" -f2- --output-delimiter=""`
		if [ $f -nt html/$f2.html ]; then 
			markdown $f > html/$f2.html
		fi
		echo "<tr><td><a href=$f2.html>$f2</a></td><td>$title</td><td>$tags</td></tr>" >> $NOTES_DIR/html/index.html	
	done
	echo "</table></body></html>" >> $NOTES_DIR/html/index.html
	lynx $NOTES_DIR/html/index.html
	cd $NOTES_PWD
}

# Generate PDFs with Pandoc
np() {
	export NOTES_PWD=`pwd`
	cd $NOTES_DIR/
	if [ ! -d "pdf" ]; then
		mkdir pdf
	fi

	if [ -z $* ]; then
		ls *.md > files.txt
	else
		grep -l "#$*" `ls -t *.md` > files.txt
	fi
	for f in `cat files.txt`
	do
		f2=${f%.*}
		if [ $f -nt pdf/$f2.pdf ]; then
			pandoc -o pdf/$f2.pdf $f
		fi
	done
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
	file=$NOTES_DIR/${1,,}-log.md
	date=$(date +%Y-%m-%d)
	if [ ! -f $file ]; then
		echo "# Log - $1" > $file
		echo "" >> $file
		echo "*Tags:* #Log #$1" >> $file
	fi
	ldate=`awk '/###/{ print $0 }' $file | tail -1 | cut -d' ' -f2`
	if [ "$ldate" != "$date" ]; then
		echo "" >> $file
		echo "### "$(date +%Y-%m-%d) >> $file
	fi
	echo -n " - " >> $file
	echo $* | cut -d' ' -f2- >> $file
}

