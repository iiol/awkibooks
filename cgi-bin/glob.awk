#!/bin/false

@include "config.awk"
@include "urldecode.awk"
@include "userops.awk"

# Global variables provided by glob.awk:
#     VAR[]
#     COOKIES[]
#     USER[]

# @desc           parse_queries - initialize VAR array
# @retval         void
func parse_queries(    bytes, cmd, query_str, vars, idx, tmp)
{
	if (ENVIRON["REQUEST_METHOD"] == "POST") {
		if (ENVIRON["CONTENT_TYPE"] == "application/x-www-form-urlencoded") {
			bytes = ENVIRON["CONTENT_LENGTH"]

			if (ENVIRON["CONTENT_LENGTH"] > MAX_POST_LEN)
				bytes = MAX_POST_LEN

			cmd = "dd ibs=1 'count=" shell_sec(bytes) "' 2>/dev/null"
			cmd | getline query_str
			close(cmd)
		}
		if (ENVIRON["QUERY_STRING"])
			query_str = query_str "&" ENVIRON["QUERY_STRING"]
	}
	else
		query_str = ENVIRON["QUERY_STRING"]

	split(query_str, vars, "&");
	for (idx in vars) {
		delete tmp
		split(vars[idx], tmp, "=")
		VAR[urldecode(tmp[1])] = urldecode(tmp[2])
	}
}

# @desc           parse_cookies - initialize COOKIES array
# @retval         void
func parse_cookies(    cookies, idx, tmp)
{
	gsub(/[ ]*/, "", ENVIRON["HTTP_COOKIE"])
	if (!ENVIRON["HTTP_COOKIE"])
		return

	split(ENVIRON["HTTP_COOKIE"], cookies, ";")
	for (idx in cookies) {
		delete tmp
		split(cookies[idx], tmp, "=")
		COOKIES[tmp[1]] = tmp[2]
	}
}

# @desc           detect_user - initialize USER array
# @retval         0 - user doesn't found, 1 - succes
func detect_user()
{
	if (COOKIES["login"] && COOKIES["token"]) {
		if (get_session(COOKIES["login"]) == COOKIES["token"] && get_user(USER, COOKIES["login"]))
			return 1

		SAVED_COOKIES["login"] = ""
		SAVED_COOKIES["token"] = ""
	}
	if (VAR["login"] && VAR["password"]) {
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

func shell_sec(str)
{
	gsub(/'/, "'\"'\"'", str)
	return str
}

BEGIN {
	parse_queries()
	parse_cookies()
	detect_user()
}
