#!/bin/false

@include "config.awk"
@include "glob.awk"

# Fields of struct book:
#   book["name"]     - book name
#   book["author"]   - book author
#   book["desc"]     - book description
#   book["tags"]     - tags
#   book["img"]      - path to cover of book
#   book["file"]     - path to book

# @desc           sprint_book - to format book
# @param[in]      book - book
# @retval         html-formatted string
func sprint_book(book,    buf, str, cmd)
{
	if (!isarray(book))
		return ""
	if (!book["name"])
		book["name"] = "NULL"
	if (!book["author"])
		book["author"] = "NULL"
	if (!book["desc"])
		book["desc"] = ""
	if (!book["img"])
		book["img"] = "default.jpg"

	buf = ""
	buf = buf "<a href=\"" BOOKPATH book["file"] "\">"
	buf = buf "<div id=\"entry\">"			# begin entry block
	buf = buf "<div id=\"book\">"			# begin book block
	buf = buf "<h1>" book["name"] "</h1>"
	buf = buf "<img src=\"" IMAGPATH book["img"] "\" alt=\"\"/>"
	buf = buf "<div id=\"text\">"			# begin text block
	buf = buf "Author: " book["author"] "<br/><br/>"

	if (book["desc"])
		buf = buf book["desc"] "<br/>"

	buf = buf "</div>"				# end of text block
	buf = buf "</div>"				# end of book block
	buf = buf "<div id=\"tags\">"			# begin tags block

	cmd = "echo '" shell_sec(book["tags"]) "'"
	while ((cmd | getline str) > 0)
		buf = buf "<a id=\"taglink\" href=\"?tag=" str "\">#" str "</a>"

	buf = buf "</div>"				# end of tags block
	buf = buf "<div style=\"clear: both\"></div>"	# positioning hack
	buf = buf "</div>"				# end of entry block
	buf = buf "</a>"

	return buf
}

# @desc           find_book_by_file - find book by file :-O
# @param[out]     book - book
# @param[in]      file - path to book
# @retval         0 - not found, 1 - found
func find_book_by_file(book, file,    str, isret, bookconf)
{
	bookconf = HOMEPATH BOOK_CONF

	if (!isarray(book))
		return 0

	while ((getline str < bookconf) > 0) {
		if (str ~ /^Author: .+/) {
			if (book["author"])
				book["author"] = book["author"] ", "

			book["author"] = book["author"] gensub(/Author: (.+)/, "\\1", "g", str)
		}
		else if (str ~ /^Tag: .+/) {
			if (book["tags"])
				book["tags"] = book["tags"] "\n"

			book["tags"] = book["tags"] gensub(/Tag: (.+)/, "\\1", "g", str)
		}
		else if (str ~ /^Name: .+/)
			book["name"] = gensub(/Name: (.+)/, "\\1", "g", str)
		else if (str ~ /^Description: .+/) {
			if (book["desc"])
				book["desc"] = book["desc"] " "

			book["desc"] = book["desc"] gensub(/Description: (.+)/, "\\1", "g", str)
		}
		else if (str ~ /^Image: .+/)
			book["img"] = gensub(/Image: (.+)/, "\\1", "g", str)
		else if (match(str, "^File:[[:space:]]+" file)) {
			isret = 1
			book["file"] = file
		}
		else if (str ~ /^---$/) {
			if (isret) {
				close(bookconf)
				return 1
			}
			delete book
		}
	}

	close(bookconf)

	return 0
}

# @desc           prefix_each_line - make prefix on each line
# @param[in]      pref - prefix
# @param[in]      buf  - buffer with lines
# @retval         formatted string
func prefix_each_line(pref, buf,    cmd, str, ret)
{
	cmd = "echo '" shell_sec(buf) "'"
	while ((cmd | getline str) > 0)
		ret = ret pref str "\n"

	close(cmd)
	return ret
}

# @desc           add_book - add book into config
# @param[in]      book - book
# @retval         void
func add_book(book,    _, buf, bookconf)
{
	bookconf = HOMEPATH BOOK_CONF

	if (!isarray(book))
		return
	if (find_book_by_file(_, book["file"]))
		return

	if (book["author"])
		buf = buf prefix_each_line("Author: ", book["author"])
	if (book["name"])
		buf = buf "Name: " book["name"] "\n"
	if (book["desc"])
		buf = buf prefix_each_line("Description: ", book["desc"])
	if (book["tags"])
		buf = buf prefix_each_line("Tag: ", book["tags"])
	if (book["img"])
		buf = buf "Image: " book["img"] "\n"
	if (book["file"])
		buf = buf "File: " book["file"] "\n"

	print buf "---" >> bookconf
}

# @desc           save_book - save book in file
# @param[in]      file      - content of file
# @param[in]      extention - extention of file
# @retval         name of saved file
func save_book(file, extention,    cmd, filename)
{
	cmd = "mktemp --suff='." shell_sec(extention) "' " HOMEPATH BOOKPATH "XXXXXXXX"
	cmd | getline filename
	close(cmd)

	print file >filename
	close(filename)

	return basename(filename)
}

# @desc           save_cover - save cover in file
# @param[in]      file - content of file
# @retval         name of saved file
func save_cover(file,    cmd, filename)
{
	cmd = "mktemp --suff=.jpg " HOMEPATH IMAGPATH "XXXXXXXX"
	cmd | getline filename
	close(cmd)

	print file >filename
	close(filename)

	return basename(filename)
}

# @desc           prep_cover - prepare cover
# @param[in]      filename - filename
# @retval         filename
func prep_cover(filename,    old, new, cmd)
{
	old = HOMEPATH IMAGPATH shell_sec(filename)
	new = old ".new"
	cmd = PREPIMG " '" old "' '" new "' && mv '" new "' '" old "'"
	system(cmd)

	return filename
}

# @desc           is_valid_img_ext - check for image file extention validity
# @param[in]      ext - extention
# @retval         0, 1
func is_valid_img_ext(ext)
{
	if (ext == "jpg")
		return 1

	return 0
}

# @desc           is_valid_book_ext - check for book file extention validity
# @param[in]      ext - extention
# @retval         0, 1
func is_valid_book_ext(ext)
{
	if (ext == "pdf" || ext == "djvu")
		return 1

	return 0
}
