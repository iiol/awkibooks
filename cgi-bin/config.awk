#!/bin/false

BEGIN {
	HOMEPATH = "/var/www/html/localhost/"

	BOOKPATH = "/resources/books/"
	IMAGPATH = "/resources/img/"
	SESSIONPATH = "/cgi-bin/sessions/"
	CSS_FILE = "/resources/style.css"

	PREPIMG = HOMEPATH "/cgi-bin/prepimg.sh"

	BOOK_CONF = "books.conf"
	USER_CONF = "users.conf"
	DEFAULT_COVER = "default.jpg"

	MAX_POST_LEN = 50*1024*1024 # 50 MiB
}
