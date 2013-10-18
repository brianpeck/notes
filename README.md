# Notes

Notes is collection of shell macros for creating, editing, and viewing notes.

Notes uses markdown for html creation, and lynx for quick terminal viewing.

## Installation
To install, simply add `source notes.sh` (or wherever you put notes.sh) in your .bashrc (or shell of choice).

Edit the `NOTES_DIR` parameter to the directory of your choice.  Defaults to `~/Dropbox/notes`.

## Usage
A number of basic commands are supported, with more added occasionally.

`n <name>` - Opens <note>.md for editing.

`nne <index>` - Opens a file with index `<index>` from last query for editing.

`nmv <old> <new>` - Renames a file from `<old>` to `<new>`

`nv <name>` - Renders and views `<name>` with lynx

`nnv <index>` - Renders and views note with index `<index>` from last query.

`nnd <index>` - Deletes note with index `<index>` from last query.

`nnat <index> <tag>` - Adds tag `<tag>` to note with index `<index>` from last query

`nnrt <index> <tag>` - Removes tag `<tag>`

`nft [<tag>]` - Searches for and lists notes with tag `<tag>` (can be empty)

`ng [<tag>]` - Generates html for all files with tag `<tag>`; creates and opens index file.

`nm <meeting>` - Creates new meeting note with curent date in name and title

`nlog <name> <item>` - Creates log with name `<name>` and adds item `<item>` with current date.
