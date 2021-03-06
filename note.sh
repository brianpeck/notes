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

# Copy the contents of a note to the clipboard
nnc() {
    cat $NOTES_DIR/`awk "NR==$1" $NOTES_DIR/files.txt` | xclip -selection clipboard
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

	# Create list of files to list
	let i=1
	ls -t *.md > files.txt
	for tag in $@
	do
		if [ $i -eq 1 ]; then
			grep -il "#$tag" `ls -t *.md` > files.txt
		else
			grep -il "#$tag" `cat files.txt` > files.txt
		fi
		let i=i+1
	done

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

	# Create list of files to list
	let i=1
	ls -t *.md > files.txt
	for tag in $@
	do
		if [ $i -eq 1 ]; then
			grep -il "#$tag" `ls -t *.md` > files.txt
		else
			grep -il "#$tag" `cat files.txt` > files.txt
		fi
		let i=i+1
	done

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


	# Create list of files to list
	let i=1
	ls -t *.md > files.txt
	for tag in $@
	do
		if [ $i -eq 1 ]; then
			grep -il "#$tag" `ls -t *.md` > files.txt
		else
			grep -il "#$tag" `cat files.txt` > files.txt
		fi
		let i=i+1
	done

	for f in `cat files.txt`
	do
		f2=${f%.*}
		if [ $f -nt pdf/$f2.pdf ]; then
			pandoc -o pdf/$f2.pdf $f
		fi
	done
	cd $NOTES_PWD
}

# Generate and view specific file with pandoc
nnp () {	
	export NOTES_PWD=`pwd`
	cd $NOTES_DIR/
	if [ ! -d "pdf" ]; then
		mkdir pdf
	fi

	f=`awk "NR==$1" files.txt`
	f2=${f%.*}
	if [ $f -nt pdf/$f2.pdf ]; then
		pandoc -o pdf/$f2.pdf $f
	fi
	# Run in subshell so no extra output is given.
	{ $PDF_VIEWER pdf/$f2.pdf & } &> /dev/null
	cd $NOTES_PWD
	
}

# Edit with preview
nnepv () {
	nnp $*
	nne $*
}

# Generate PDF with no tags
nnpnt () {
	export NOTES_PWD=`pwd`
	cd $NOTES_DIR/
	if [ ! -d "pdf" ]; then
		mkdir pdf
	fi

	f=`awk "NR==$1" files.txt`
	f2=${f%.*}
	if [ $f -nt pdf/$f2.pdf ]; then
		sed "/Tags/d" $f | pandoc -o pdf/$f2.pdf
	fi
	# Run in subshell so no extra output is given.
	{ $PDF_VIEWER pdf/$f2.pdf & } &> /dev/null
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

# Create new meeting note and open a preview
nmpv () {
	title=${1,,}$(date +%Y%m%d)
	file=$NOTES_DIR/$title.md
	if [ ! -f $file ]; then
		echo "# $1 Meeting Notes - `date +%Y-%m-%d`" > $file
		echo "" >> $file
		echo "*Tags:* #Meeting #$1" >> $file
		echo "" >> $file
	fi
	pandoc -o $NOTES_DIR/pdf/$title.pdf $file
	{ $PDF_VIEWER $NOTES_DIR/pdf/$title.pdf & } &> /dev/null

	$EDITOR $file
}

# Create a new journal entry
# Usage: nj
nj () {
	file=$NOTES_DIR/journal-$(date +%Y%m%d).md
	if [ ! -f $file ]; then
		echo "# Journal - `date +%Y-%m-%d`" > $file
		echo "" >> $file
		echo "*Tags:* #Journal" >> $file
		echo "" >> $file
	fi
	$EDITOR $file
}

# Journal with preview mode
njpv () {
	title=journal-$(date +%Y%m%d)
	file=$NOTES_DIR/$title.md
	if [ ! -f $file ]; then
		echo "# Journal - `date +%Y-%m-%d`" > $file
		echo "" >> $file
		echo "*Tags:* #Journal" >> $file
		echo "" >> $file
	fi

	pandoc -o $NOTES_DIR/pdf/$title.pdf $file
	{ $PDF_VIEWER $NOTES_DIR/pdf/$title.pdf & } &> /dev/null

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


