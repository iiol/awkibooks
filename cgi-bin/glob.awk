#!/bin/false

@include "config.awk"
@include "urldecode.awk"
@include "userops.awk"

# Global variables provided by glob.awk:
#     VAR[]
#     COOKIES[]
#     USER[]

# @desc           parse_header - parse header
# @param[out]     header - parsed header
# @param[in]      str    - header
# @retval         void
func parse_header(header, str,    idx)
{
	delete header
	header["info"][""]   = ""
	header["param"][""] = ""

	sub(/\r$/, "", str)

	if (match(str, /^[[:alnum:]-]+[[:space:]]*:.+$/)) {
		header["info"]["header"] = gensub(/^([[:alnum:]-]+)[[:space:]]*:.+$/, "\\1", "g", str)
		sub(/^[[:alnum:]-]+[[:space:]]*:[[:space:]]*/, "", str)
	}

	# TODO: rewrite algorithm to the one that not match ';' in "strings"
	split(str, header["param"], ";")
	for (idx in header["param"]) {
		sub(/^[[:space:]]+/, "", header["param"][idx])
		sub(/[[:space:]]+$/, "", header["param"][idx])
	}
}

# @desc           parse_var - parse variable
# @param[out]     arr - array of variables
# @param[in]      var - string with variable
# @retval         void
func parse_var(arr, var,    key, value)
{
	if (match(var, /^[[:space:]]*[^=[:space:]]+="(\\.|[^\\"])*".*$/)) {
		key = gensub(/^[[:space:]]*([^=[:space:]]+)=[[:space:]]*"(\\.|[^\\"])*".*$/, "\\1", "g", var)
		value = gensub(/^[[:space:]]*[^=[:space:]]+=[[:space:]]*"((\\.|[^\\"])*)".*$/, "\\1", "g", var)
	}
	else if (match(var, /^[[:space:]]*[^=[:space:]]+=[^"][^[:space:]]*.*$/)) {
		key = gensub(/^[[:space:]]*([^=[:space:]]+)=[^"][^[:space:]]*.*$/, "\\1", "g", var)
		value = gensub(/^[[:space:]]*[^=[:space:]]+=([^"][^[:space:]]*).*$/, "\\1", "g", var)
	}

	sub(/^[[:space:]]+/, "", key)
	sub(/[[:space:]]+$/, "", key)
	arr[key] = value
}

# @desc           uniq - return unique and sorted strings
# @param[in]      buf - buffer of strings
# @retval         void
func uniq(buf,    cmd, str, ret)
{
	cmd = "echo '" shell_sec(buf) "' | sort | uniq"

	while ((cmd | getline str) > 0)
		ret = ret str "\n"

	sub(/\n$/, "", ret)

	return ret
}

# @desc           parse_queries - initialize VAR array
# @retval         void
func parse_queries(    bytes, cmd, query_str, head, idx, cont_type, boundary, stat, str, strr, part_type, var, vars, tmp)
{
	if (ENVIRON["REQUEST_METHOD"] == "POST") {
		bytes = ENVIRON["CONTENT_LENGTH"]

		if (ENVIRON["CONTENT_LENGTH"] > MAX_POST_LEN)
			bytes = MAX_POST_LEN

		cmd = "dd ibs=1 'count=" shell_sec(bytes) "' 2>/dev/null"

		if (ENVIRON["CONTENT_TYPE"] == "application/x-www-form-urlencoded") {
			cmd | getline query_str
			close(cmd)
		}
		else if (match(ENVIRON["CONTENT_TYPE"], "^multipart/form-data;.*")) {
			parse_header(head, ENVIRON["CONTENT_TYPE"])
			for (idx = 2; head["param"][idx]; ++idx)
				parse_var(cont_type, head["param"][idx])

			boundary = cont_type["boundary"]
			delete cont_type

			stat = "none"
			while ((cmd | getline strr) > 0) {
				str = strr
				sub(/\r$/, "", str)
				if (str == "--" boundary) {
					stat = "header"
					part_type = ""
					continue
				}
				else if (str == "--" boundary "--")
					break

				if (stat == "none")
					continue
				else if (stat == "header") {
					if (!str) {
						stat = "content"
						continue
					}

					parse_header(head, str)
					if (head["info"]["header"] != "Content-Disposition")
						continue

					# Content-Disposition processing
					delete var
					for (idx = 2; head["param"][idx]; ++idx)
						parse_var(var, head["param"][idx])

					part_type = var["name"]

					if (part_type == "image") {
						if (!is_valid_img_ext(gensub(/^.*\.([^\.]*)$/, "\\1", "g", var["filename"])))
							break
					}
					else if (part_type == "file") {
						FILE["extention"] = gensub(/^.*\.([^\.]*)$/, "\\1", "g", var["filename"])
						if (!is_valid_book_ext(FILE["extention"]))
							break
					}
					else if (part_type != "name"    &&
						 part_type != "authors" &&
						 part_type != "desc"    &&
						 part_type != "tags")
						part_type = ""
				}
				else if (stat == "content") {
					if (part_type == "name"    ||
					    part_type == "authors" ||
					    part_type == "desc"    ||
					    part_type == "tags")
						FILE[part_type] = FILE[part_type] str "\n"
					else if (part_type == "image" ||
						 part_type == "file")
						FILE[part_type] = FILE[part_type] strr "\n"
				}
			}

			close(cmd)

			gsub(/[[:space:]]+/, " ", FILE["name"])
			gsub(/\n+/, "\n", FILE["authors"])
			gsub(/\n+/, "\n", FILE["desc"])
			gsub(/[[:space:]]+/, "", FILE["tags"])
			gsub(/,/, "\n", FILE["tags"])

			sub(/^[[:space:]]+/, "", FILE["name"])
			sub(/[[:space:]]+$/, "", FILE["name"])
			sub(/^[[:space:]]+/, "", FILE["authors"])
			sub(/[[:space:]]+$/, "", FILE["authors"])
			sub(/^[[:space:]]+/, "", FILE["desc"])
			sub(/[[:space:]]+$/, "", FILE["desc"])
			sub(/^[[:space:]]+/, "", FILE["tags"])
			sub(/[[:space:]]+$/, "", FILE["tags"])

			FILE["tags"] = uniq(tolower(FILE["tags"]))

			if (!FILE["name"] || !FILE["authors"] || !FILE["tags"])
				delete FILE
		}
	}

	if (query_str && ENVIRON["QUERY_STRING"])
		query_str = query_str "&" ENVIRON["QUERY_STRING"]
	else if (ENVIRON["QUERY_STRING"])
		query_str = ENVIRON["QUERY_STRING"]

	split(query_str, vars, "&")
	for (idx in vars) {
		delete tmp
		split(vars[idx], tmp, "=")
		VAR[urldecode(tmp[1])] = urldecode(tmp[2])
	}
}

# @desc           parse_cookies - initialize COOKIES array
# @retval         void
func parse_cookies(    header, idx)
{
	parse_header(header, ENVIRON["HTTP_COOKIE"])
	for (idx in header["param"])
		parse_var(COOKIES, header["param"][idx])
}

# @desc           detect_user - initialize USER array
# @retval         0 - user doesn't found, 1 - succes
func detect_user()
{
	if (COOKIES["login"] && COOKIES["token"]) {
		if (get_session(COOKIES["login"]) == COOKIES["token"]) {
			if (get_user(USER, COOKIES["login"]))
				return 1

			delete_session(COOKIES["login"], COOKIES["token"])
		}

		SAVED_COOKIES["login"] = ""
		SAVED_COOKIES["token"] = ""
	}
	if (VAR["login"] && VAR["password"]) {
		VAR["password"] = hash_password(VAR["login"], VAR["password"])
		if (get_user(USER, VAR["login"]) && VAR["password"] == USER["password"]) {
			SAVED_COOKIES["login"] = VAR["login"]
			SAVED_COOKIES["token"] = get_session(VAR["login"])

			return 1
		}

		STATES["unknown_user"] = 1
	}

	delete USER
	get_user(USER, "anonymous")

	return 0
}

# @desc           shell_sec - make secure to use variable in shell in single quotes
# @param[in]      str - string
# @retval         string
func shell_sec(str)
{
	gsub(/'/, "'\"'\"'", str)
	return str
}

# @desc           basename - return basename of file by path
# @param[in]      path - path to file
# @retval         base name
function basename(path)
{
	sub(".*/", "", path)
	return path
}


# @desc           hash_password - hash password of user
# @param[in]      user - username
# @param[in]      password - password of user
# @retval         hashed password
func hash_password(user, password,    cmd, hash)
{
	cmd = "echo '" shell_sec(user password) "' | sha1sum | cut -d ' ' -f 1"
	cmd | getline hash
	close(cmd)

	return hash
}

BEGIN {
	parse_queries()
	parse_cookies()
	detect_user()

	if (VAR["newuser"] && VAR["newpasswd"]) {
		user["name"] = VAR["newuser"]
		user["password"] = hash_password(VAR["newuser"], VAR["newpasswd"])

		if (VAR["upload"] == "on")
			user["upload"] = "true"
		if (VAR["remove"] == "on")
			user["remove"] = "true"
		if (VAR["adduser"] == "on")
			user["adduser"] = "true"

		add_user(user)
		REDIRECT = "/"
	}
	if (FILE["name"]) {
		book["name"]   = FILE["name"]
		book["author"] = FILE["authors"]
		book["desc"]   = FILE["desc"]
		book["tags"]   = FILE["tags"]

		if (FILE["image"])
			book["img"] = prep_cover(save_cover(FILE["image"]))
		else
			book["img"] = DEFAULT_COVER

		book["file"] = save_book(FILE["file"], FILE["extention"])
		add_book(book)
	}
}
