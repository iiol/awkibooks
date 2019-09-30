#!/usr/bin/awk -f

@include "./hexcodes.awk"

# Global variables:
#
# author -- author name
# name   -- book name
# desc   -- description of book
# image  -- path to preview image of book
# tag    -- tags list of book

func urldecode(text,    hex, i, hextab, decoded, len, c, c1, c2, code) {
	# urldecode function from Heiner Steven
	# http://www.shelldorado.com/scripts/cmds/urldecode

	split("0 1 2 3 4 5 6 7 8 9 a b c d e f", hex, " ")
	for (i = 0; i < 16; i++)
		hextab[hex[i+1]] = i

	decoded = ""
	i = 1
	len = length(text)

	while (i <= len) {
		c = substr (text, i, 1)
		if (c == "%") {
			if (i + 2 <= len) {
				c1 = tolower(substr(text, i + 1, 1))
				c2 = tolower(substr(text, i + 2, 1))
				if (hextab [c1] != "" || hextab [c2] != "") {
					code = 0 + hextab[c1] * 16 + hextab[c2] + 0
					c = hexval[code]
					i = i + 2
				}
			}
		} else if ( c == "+" ) {
			# special handling: "+" means " "
			c = " "
		}

		decoded = decoded c
		++i
	}

	# change linebreaks to \n
	gsub(/\r\n/, "\n", decoded)

	# remove last linebreak
	sub(/[\n\r]*$/,"", decoded)

	return decoded
}

func print_header(title) {
	print "Content-Type: text/html; charset=utf-8\r\n"
	print "<html>"
	print "<head>"
	print "<link rel=\"stylesheet\" type=\"text/css\" href=\"/resources/style.css\">"
	print "<meta charset=\"UTF-8\">"
	print "<title>" title "</title>"
	print "</head>"
	print "<body>"
	print "<div id=\"page\">"
	print "<div id=\"menu\">"
	print "Hello World<br>"
	print "TODO"
	print "</div>"
	print "<div id=\"booklist\">"
}

func print_footer() {
	print "</div></div>"
	print "</body>"
	print "</html>"
}

func print_book() {
	if (!name)
		name = "NULL"
	if (!author)
		author = "NULL"
	if (!desc)
		desc = ""
	if (!image)
		image = "default.jpg"

	print "<a href=\"/resources/books/" filename "\">"
	print "<div id=\"entry\">"
	print "<div id=\"book\">"
	print "<h1>" name "</h1>"
	print "<img src=\"/resources/img/" image "\" alt=\"\">"
	print "<div id=\"text\">"
	print "Author: " author "<br><br>"

	if (desc)
		print desc "<br>"

	print "</div>"					# div id="text"
	print "</div>"					# div id="book"
	print "</a>"
	print "<div id=\"tags\">"

	cmd = "echo '" tag "'"
	while ((cmd | getline str) > 0)
		print "<a href=\"?tag=" str "\">#" str "</a>"

	print "</div>"					# div id="tags"
	print "<div style=\"clear: both\"></div>"	# positioning hack
	print "</div>"					# div id="entry"
}

BEGIN {
	configfile = ENVIRON["DOCUMENT_ROOT"] "./books.conf"


	split(ENVIRON["QUERY_STRING"], vars, "&");
	for (idx in vars) {
		delete tmp
		split(vars[idx], tmp, "=")
		VAR[urldecode(tmp[1])] = urldecode(tmp[2])
	}

	delete tmp
	delete vars

	print_header("Books")

	while ((getline < configfile) > 0) {
		if (/^Author: .+/)
			author = author ", " gensub(/Author: (.+)/, "\\1", "g")
		else if (/^Tag: .+/)
			tag = tag "\n" gensub(/Tag: (.+)/, "\\1", "g")
		else if (/^Name: .+/)
			name = gensub(/Name: (.+)/, "\\1", "g")
		else if (/^Description: .+/)
			desc = desc " " gensub(/Description: (.+)/, "\\1", "g")
		else if (/^Image: .+/)
			image = gensub(/Image: (.+)/, "\\1", "g")
		else if (/^File: .+/)
			filename = gensub(/File: (.+)/, "\\1", "g");
		else if (/^---$/) {
			author = substr(author, 3)
			tag = substr(tag, 2)

			if (VAR["tag"] && match(tag, "(^|\n)" VAR["tag"] "($|\n)") ||
			    !VAR["tag"])
				print_book()

			author = name = desc = image = tag = ""
		}
	}

	author = substr(author, 3)
	tag = substr(tag, 2)

	if (VAR["tag"] && match(tag, "(^|\n)" VAR["tag"] "($|\n)") ||
	    !VAR["tag"])
		print_book()

	print_footer()
}
