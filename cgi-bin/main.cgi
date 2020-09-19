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
		buf = buf "</div></div>"
		buf = buf "<div id=\"button\">"
		buf = buf "<input type=\"submit\" name=\"button\" value=\"Вход\"/>"
		buf = buf "</div>"
		buf = buf "</form>"
	}
	else {
		buf = buf "<div id=\"username\">"
		buf = buf "Hello, " USER["name"]
		buf = buf "</div>"
	}

	buf = buf "<form name=\"searchform\" method=\"GET\" action=\"/cgi-bin/main.cgi\">"
	buf = buf "<label for=\"search\">Поиск по книгам:</lavel>"
	buf = buf "<input type=\"text\" name=\"search\" id=\"search\"/>"
	buf = buf "<div id=\"button\">"
	buf = buf "<input type=\"submit\" name=\"button\" value=\"Найти\"/>"
	buf = buf "</div>"
	buf = buf "</form>"
	buf = buf "<br/>"

	if (USER["upload"] == "true")
		buf = buf "<a id=\"action\" href=\"?action=upload\">Загрузить книгу</a><br/>"
	if (USER["remove"] == "true")
		buf = buf "<a id=\"action\" href=\"?action=remove\">Удалить книгу</a><br/>"
	if (USER["adduser"] == "true")
		buf = buf "<a id=\"action\" href=\"?action=adduser\">Добавить пользователя</a><br/>"

	buf = buf "<div id=\"taglist\">"
	buf = buf "Все теги:<br/>"

	cmd = "cat '" bookconf "' | grep '^Tag: ' | cut -d ' ' -f 2 | sort | uniq"
	while ((cmd | getline str) > 0)
		buf = buf "<a id=\"taglink\" href=\"?tag=" str "\">#" str "</a><br/>"

	close(cmd)

	buf = buf "</div>"

	return buf
}

func format_booklist(    cmd, file, book, buf)
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

func format_adduser(    buf)
{
	buf = buf "<form name=\"adduser\" method=\"POST\" action=\"/cgi-bin/main.cgi\">"
	buf = buf "<input type=\"text\" name=\"newuser\"/><br/>"
	buf = buf "<input type=\"password\" name=\"newpasswd\"/><br/>"
	buf = buf "<input type=\"checkbox\" name=\"upload\" id=\"upload\">"
	buf = buf "<label for=\"upload\">Upload</label><br/>"
	buf = buf "<input type=\"checkbox\" name=\"remove\" id=\"remove\">"
	buf = buf "<label for=\"remove\">Remove</label><br/>"
	buf = buf "<input type=\"checkbox\" name=\"adduser\" id=\"adduser\">"
	buf = buf "<label for=\"adduser\">Add user</label><br/>"
	buf = buf "<input type=\"submit\" name=\"button\" value=\"Отправить\"/>"
	buf = buf "</form>"

	return buf
}

func format_upload(    buf)
{
	buf = buf "<form name=\"upload_book\" method=\"POST\" action=\"/cgi-bin/main.cgi\" enctype=\"multipart/form-data\">"
	buf = buf "<label for=\"name\">Name:</label><br/>"
	buf = buf "<input type=\"text\" id=\"name\" name=\"name\"><br/><br/>"

	buf = buf "<label for=\"authors\">Authors (each on new line):</label><br/>"
	buf = buf "<textarea id=\"authors\" name=\"authors\" rows=\"5\" cols=\"50\"></textarea></br></br>"

	buf = buf "<label for=\"desc\">Description:</label><br/>"
	buf = buf "<textarea id=\"desc\" name=\"desc\" rows=\"5\" cols=\"50\"></textarea></br></br>"

	buf = buf "<label for=\"tags\">Comma separated tags:</label><br/>"
	buf = buf "<textarea id=\"tags\" name=\"tags\" rows=\"2\" cols=\"50\"></textarea></br></br>"

	buf = buf "<label for=\"image\">Book cover (with .jpg extention): </label>"
	buf = buf "<input type=\"file\" id=\"image\" name=\"image\"><br/><br/>"

	buf = buf "<label for=\"file\">Book file (with .pdf or .djvu extention): </label>"
	buf = buf "<input type=\"file\" id=\"file\" name=\"file\"/><br/><br/>"

	buf = buf "<input type=\"submit\" name=\"button\" value=\"Отправить\"/><br/>"
	buf = buf "</form>"
	return buf
}

func format_body(    buf)
{
	if (VAR["action"] == "adduser" && USER["adduser"] == "true")
		buf = format_adduser()
	else if (VAR["action"] == "upload" && USER["upload"] == "true")
		buf = format_upload()
	else
		buf = format_booklist()

	return buf
}

func format_headers(    buf)
{
	buf = ""
	buf = buf "Content-Type: text/html; charset=utf-8\n"

	if (REDIRECT)
		buf = buf "Location: " REDIRECT "\n"

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
	buf = buf "<div id=\"body\">"			# begin of body
	buf = buf format_body()
	buf = buf "</div>"				# end of body
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
}

BEGIN {main()}
