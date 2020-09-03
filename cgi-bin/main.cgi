#!/usr/bin/gawk -f

@include "urldecode.awk"
@include "bookops.awk"
@include "config.awk"

func print_menu(    str, cmd, bookconf)
{
	bookconf = HOMEPATH BOOK_CONF

	print "Поиск по книгам:"
	print "<form name=\"searchform\" method=\"get\" action=\"/cgi-bin/main.cgi\">"
	print "<input type=\"text\" name=\"search\">"
	print "<div id=\"button\">"
	print "<input type=\"submit\" name=\"button\" value=\"Search\">"
	print "</div>"
	print "<div id=\"taglist\">"
	print "Все теги:<br><br>"

	cmd = "cat '" bookconf "' | grep '^Tag: ' | cut -d ' ' -f 2 | sort | uniq"
	while ((cmd | getline str) > 0)
		print "<a id=\"taglink\" href=\"?tag=" str "\">#" str "</a><br>"

	close(cmd)

	print "</div>"
	print "</form>"
}

func print_body(    cmd, file, book)
{
	# Hack for making book an array
	book[""] = ""; delete book

	cmd = "ls " HOMEPATH BOOKPATH
	while ((cmd | getline file) > 0) {
		if (!find_book_by_file(book, file))
			continue
		if (VAR["tag"] && match(book["tags"], "(^|\n)" VAR["tag"] "($|\n)") ||
		   !VAR["tag"] && !VAR["search"])
			print sprint_book(book)
		else if (VAR["search"] && (                                 \
		    match(tolower(book["author"]), tolower(VAR["search"])) ||
		    match(tolower(book["desc"]),   tolower(VAR["search"])) ||
		    match(tolower(book["name"]),   tolower(VAR["search"]))))
			print sprint_book(book)
	}

	close(cmd)
}

func print_html(title)
{
	print "Content-Type: text/html; charset=utf-8\r\n"
	print "<html>"
	print "<head>"
	print "<link rel=\"stylesheet\" type=\"text/css\" href=\"" CSS_FILE "\">"
	print "<meta charset=\"UTF-8\">"
	print "<title>" title "</title>"
	print "</head>"
	print "<body>"
	print "<div id=\"page\">"
	print "<div id=\"menu\">"
	print_menu()
	print "</div>"
	print "<div id=\"booklist\">"
	print_body()
	print "</div></div>"
	print "</body>"
	print "</html>"
}

func main(    idx, vars, tmp)
{
	split(ENVIRON["QUERY_STRING"], vars, "&");
	for (idx in vars) {
		delete tmp
		split(vars[idx], tmp, "=")
		VAR[urldecode(tmp[1])] = urldecode(tmp[2])
	}

	delete tmp
	delete vars

	print_html("Books")
}

BEGIN {main()}
