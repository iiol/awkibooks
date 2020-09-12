#!/usr/bin/gawk -f

@include "urldecode.awk"
@include "bookops.awk"
@include "userops.awk"
@include "config.awk"
@include "glob.awk"

func format_menu(    str, cmd, bookconf, buf)
{
	bookconf = HOMEPATH BOOK_CONF
	buf = ""

	if (!USER["name"] || USER["name"] == "anonymous") {
		buf = buf "Вход:"
		buf = buf "<form name=\"signin\" method=\"POST\" action=\"/cgi-bin/main.cgi\">"
		buf = buf "<div id=\"signin_fields\">"
		buf = buf "<input type=\"text\" name=\"login\"/>"
		buf = buf "<input type=\"password\" name=\"password\"/>"
		buf = buf "<div id=\"message\">"
		if (STATES["unknown_user"])
			buf = buf "Неверный пользователь или пароль"
		buf = buf "</div>"
		buf = buf "</div><div id=\"button\">"
		buf = buf "<input type=\"submit\" name=\"button\" value=\"Вход\"/>"
		buf = buf "</div>"
		buf = buf "</form>"
	}
	else {
		buf = buf "<div id=\"username\">"
		buf = buf "Hello, " USER["name"]
		buf = buf "</div>"
	}

	buf = buf "Поиск по книгам:"
	buf = buf "<form name=\"searchform\" method=\"GET\" action=\"/cgi-bin/main.cgi\">"
	buf = buf "<input type=\"text\" name=\"search\"/>"
	buf = buf "<div id=\"button\">"
	buf = buf "<input type=\"submit\" name=\"button\" value=\"Найти\"/>"
	buf = buf "</div>"
	buf = buf "</form>"
	buf = buf "<div id=\"taglist\">"
	buf = buf "Все теги:<br/><br/>"

	cmd = "cat '" bookconf "' | grep '^Tag: ' | cut -d ' ' -f 2 | sort | uniq"
	while ((cmd | getline str) > 0)
		buf = buf "<a id=\"taglink\" href=\"?tag=" str "\">#" str "</a><br/>"

	close(cmd)

	buf = buf "</div>"

	return buf
}

func format_body(    cmd, file, book, buf)
{
	buf = ""

	# Hack for making variables an array
	book[""] = ""; delete book

	cmd = "ls " HOMEPATH BOOKPATH
	while ((cmd | getline file) > 0) {
		if (!find_book_by_file(book, file))
			continue
		if (VAR["tag"] && match(book["tags"], "(^|\n)" VAR["tag"] "($|\n)") ||
		   !VAR["tag"] && !VAR["search"])
			buf = buf sprint_book(book)
		else if (VAR["search"] && (                                 \
		    match(tolower(book["author"]), tolower(VAR["search"])) ||
		    match(tolower(book["desc"]),   tolower(VAR["search"])) ||
		    match(tolower(book["name"]),   tolower(VAR["search"]))))
			buf = buf sprint_book(book)
	}

	close(cmd)

	return buf
}

func format_headers(    buf)
{
	buf = ""
	buf = buf "Content-Type: text/html; charset=utf-8\n"

	for (idx in SAVED_COOKIES)
		buf = buf "Set-Cookie: " idx "=" SAVED_COOKIES[idx] "; path=/\n"

	return buf
}

func format_html(title,    buf)
{
	buf = ""
	buf = buf "<html>"
	buf = buf "<head>"
	buf = buf "<link rel=\"stylesheet\" type=\"text/css\" href=\"" CSS_FILE "\"/>"
	buf = buf "<meta charset=\"UTF-8\"/>"
	buf = buf "<title>" title "</title>"
	buf = buf "</head>"
	buf = buf "<body>"
	buf = buf "<div id=\"page\">"			# begin of page
	buf = buf "<div id=\"menu\">"			# begin of menu
	buf = buf format_menu()
	buf = buf "</div>"				# end of menu
	buf = buf "<div id=\"booklist\">"		# begin of booklist
	buf = buf format_body()
	buf = buf "</div>"				# end of booklist
	buf = buf "</div>"				# end of page
	buf = buf "</body>"
	buf = buf "</html>"

	return buf
}

func main(    html, head)
{
	html = format_html("Books")
	head = format_headers()

	print head
	print html
	print GLOB
}

BEGIN {main()}
