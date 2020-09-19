#!/bin/false

@include "config.awk"

# Fields of struct user
# user["name"]     - username
# user["password"] - sha1 hash of password
# user["remove"]   - remove right
# user["upload"]   - upload right
# user["adduser"]  - add user right

# @desc           get_user - get user by username
# @param[out]     user     - user
# @param[in]      username - username
# @retval         0 - user doesn't exist, 1 - success
func get_user(user, username,    isret)
{
	userconf = HOMEPATH USER_CONF

	while ((getline str < userconf) > 0) {
		if (match(str, "^Username:[[:space:]]+" username "$")) {
			user["name"] = username
			isret = 1
		}
		else if (str ~ /^Password: .+/)
			user["password"] = gensub(/Password: (.+)/, "\\1", "g", str)
		else if (str ~ /^UploadBook: .+/)
			user["upload"] = gensub(/UploadBook: (.+)/, "\\1", "g", str)
		else if (str ~ /^RemoveBook: .+/)
			user["remove"] = gensub(/RemoveBook: (.+)/, "\\1", "g", str)
		else if (str ~ /^AddUser: .+/)
			user["adduser"] = gensub(/AddUser: (.+)/, "\\1", "g", str)
		else if (str ~ /^---$/) {
			if (isret) {
				close(userconf)
				return 1
			}
			delete user
		}
	}

	close(userconf)
	return 0
}

# @desc           add_user - add new user in config
# @param[in]      user     - struct with user data
# @retval         void
func add_user(user,    _, userconf, buf)
{
	userconf = HOMEPATH USER_CONF

	if (!user["name"] || !user["password"] || get_user(_, user["name"]))
		return 0

	# TODO: delete first buf
	buf = ""
	buf = buf "Username: "     user["name"] "\n"
	buf = buf "Password: "     user["password"] "\n"
	buf = buf "UploadBook: " ((user["upload"] == "true") ? "true\n" : "false\n")
	buf = buf "RemoveBook: " ((user["remove"] == "true") ? "true\n" : "false\n")
	buf = buf "AddUser: "    ((user["adduser"] == "true") ? "true\n" : "false\n")
	buf = buf "---"

	print buf >> userconf
	close(userconf)
}

# @desc           find_session - find existed session of user
# @param[in]      username - username
# @retval         string with token or empty string
func find_session(username,    cmd, cmd2, file, token)
{
	cmd = "ls " HOMEPATH SESSIONPATH
	while ((cmd | getline file) > 0) {
		if (file != username)
			continue

		cmd2 = "cat '" HOMEPATH SESSIONPATH shell_sec(file) "'"
		cmd2 | getline token
		close(cmd2)
		close(cmd)
		return token
	}

	close(cmd)
	return ""
}

# @desc           get_session - find or create session
# @param[in]      username - username
# @retval         string with token
func get_session(username,    session_file, token, cmd)
{
	session_file = HOMEPATH SESSIONPATH username

	token = find_session(username)
	if (token)
		return token


	cmd = "cat /dev/urandom | tr -cd '[:alnum:]' | head -c 16"
	cmd | getline token
	close(cmd)

	print token > session_file
	close(session_file)

	return token
}

# @desc           delete_session - delete session for user
# @param[in]      username - username
# @param[in]      token    - token of user
# @retval         0 - session not deleted, 1 - session deleted
func delete_session(username, token,    file_token, cmd)
{
	file_token = find_session(username)
	if (!file_token || token != file_token)
		return 0

	cmd = "rm '" HOMEPATH SESSIONPATH shell_sec(username) "'"
	system(cmd)

	return 1
}
