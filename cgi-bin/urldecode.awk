#!/bin/false

#awk 'BEGIN{print "BEGIN {"; for (i = 0; i <= 0xff; i++) printf("hexval[0x%x] = \"\\x%2.2x\";\n", i, i); print "}"}' > hexcodes.awk
BEGIN {
	hexval[0x0] = "\x00";  hexval[0x1] = "\x01";  hexval[0x2] = "\x02";  hexval[0x3] = "\x03";
	hexval[0x4] = "\x04";  hexval[0x5] = "\x05";  hexval[0x6] = "\x06";  hexval[0x7] = "\x07";
	hexval[0x8] = "\x08";  hexval[0x9] = "\x09";  hexval[0xa] = "\x0a";  hexval[0xb] = "\x0b";
	hexval[0xc] = "\x0c";  hexval[0xd] = "\x0d";  hexval[0xe] = "\x0e";  hexval[0xf] = "\x0f";
	hexval[0x10] = "\x10"; hexval[0x11] = "\x11"; hexval[0x12] = "\x12"; hexval[0x13] = "\x13";
	hexval[0x14] = "\x14"; hexval[0x15] = "\x15"; hexval[0x16] = "\x16"; hexval[0x17] = "\x17";
	hexval[0x18] = "\x18"; hexval[0x19] = "\x19"; hexval[0x1a] = "\x1a"; hexval[0x1b] = "\x1b";
	hexval[0x1c] = "\x1c"; hexval[0x1d] = "\x1d"; hexval[0x1e] = "\x1e"; hexval[0x1f] = "\x1f";
	hexval[0x20] = "\x20"; hexval[0x21] = "\x21"; hexval[0x22] = "\x22"; hexval[0x23] = "\x23";
	hexval[0x24] = "\x24"; hexval[0x25] = "\x25"; hexval[0x26] = "\x26"; hexval[0x27] = "\x27";
	hexval[0x28] = "\x28"; hexval[0x29] = "\x29"; hexval[0x2a] = "\x2a"; hexval[0x2b] = "\x2b";
	hexval[0x2c] = "\x2c"; hexval[0x2d] = "\x2d"; hexval[0x2e] = "\x2e"; hexval[0x2f] = "\x2f";
	hexval[0x30] = "\x30"; hexval[0x31] = "\x31"; hexval[0x32] = "\x32"; hexval[0x33] = "\x33";
	hexval[0x34] = "\x34"; hexval[0x35] = "\x35"; hexval[0x36] = "\x36"; hexval[0x37] = "\x37";
	hexval[0x38] = "\x38"; hexval[0x39] = "\x39"; hexval[0x3a] = "\x3a"; hexval[0x3b] = "\x3b";
	hexval[0x3c] = "\x3c"; hexval[0x3d] = "\x3d"; hexval[0x3e] = "\x3e"; hexval[0x3f] = "\x3f";
	hexval[0x40] = "\x40"; hexval[0x41] = "\x41"; hexval[0x42] = "\x42"; hexval[0x43] = "\x43";
	hexval[0x44] = "\x44"; hexval[0x45] = "\x45"; hexval[0x46] = "\x46"; hexval[0x47] = "\x47";
	hexval[0x48] = "\x48"; hexval[0x49] = "\x49"; hexval[0x4a] = "\x4a"; hexval[0x4b] = "\x4b";
	hexval[0x4c] = "\x4c"; hexval[0x4d] = "\x4d"; hexval[0x4e] = "\x4e"; hexval[0x4f] = "\x4f";
	hexval[0x50] = "\x50"; hexval[0x51] = "\x51"; hexval[0x52] = "\x52"; hexval[0x53] = "\x53";
	hexval[0x54] = "\x54"; hexval[0x55] = "\x55"; hexval[0x56] = "\x56"; hexval[0x57] = "\x57";
	hexval[0x58] = "\x58"; hexval[0x59] = "\x59"; hexval[0x5a] = "\x5a"; hexval[0x5b] = "\x5b";
	hexval[0x5c] = "\x5c"; hexval[0x5d] = "\x5d"; hexval[0x5e] = "\x5e"; hexval[0x5f] = "\x5f";
	hexval[0x60] = "\x60"; hexval[0x61] = "\x61"; hexval[0x62] = "\x62"; hexval[0x63] = "\x63";
	hexval[0x64] = "\x64"; hexval[0x65] = "\x65"; hexval[0x66] = "\x66"; hexval[0x67] = "\x67";
	hexval[0x68] = "\x68"; hexval[0x69] = "\x69"; hexval[0x6a] = "\x6a"; hexval[0x6b] = "\x6b";
	hexval[0x6c] = "\x6c"; hexval[0x6d] = "\x6d"; hexval[0x6e] = "\x6e"; hexval[0x6f] = "\x6f";
	hexval[0x70] = "\x70"; hexval[0x71] = "\x71"; hexval[0x72] = "\x72"; hexval[0x73] = "\x73";
	hexval[0x74] = "\x74"; hexval[0x75] = "\x75"; hexval[0x76] = "\x76"; hexval[0x77] = "\x77";
	hexval[0x78] = "\x78"; hexval[0x79] = "\x79"; hexval[0x7a] = "\x7a"; hexval[0x7b] = "\x7b";
	hexval[0x7c] = "\x7c"; hexval[0x7d] = "\x7d"; hexval[0x7e] = "\x7e"; hexval[0x7f] = "\x7f";
	hexval[0x80] = "\x80"; hexval[0x81] = "\x81"; hexval[0x82] = "\x82"; hexval[0x83] = "\x83";
	hexval[0x84] = "\x84"; hexval[0x85] = "\x85"; hexval[0x86] = "\x86"; hexval[0x87] = "\x87";
	hexval[0x88] = "\x88"; hexval[0x89] = "\x89"; hexval[0x8a] = "\x8a"; hexval[0x8b] = "\x8b";
	hexval[0x8c] = "\x8c"; hexval[0x8d] = "\x8d"; hexval[0x8e] = "\x8e"; hexval[0x8f] = "\x8f";
	hexval[0x90] = "\x90"; hexval[0x91] = "\x91"; hexval[0x92] = "\x92"; hexval[0x93] = "\x93";
	hexval[0x94] = "\x94"; hexval[0x95] = "\x95"; hexval[0x96] = "\x96"; hexval[0x97] = "\x97";
	hexval[0x98] = "\x98"; hexval[0x99] = "\x99"; hexval[0x9a] = "\x9a"; hexval[0x9b] = "\x9b";
	hexval[0x9c] = "\x9c"; hexval[0x9d] = "\x9d"; hexval[0x9e] = "\x9e"; hexval[0x9f] = "\x9f";
	hexval[0xa0] = "\xa0"; hexval[0xa1] = "\xa1"; hexval[0xa2] = "\xa2"; hexval[0xa3] = "\xa3";
	hexval[0xa4] = "\xa4"; hexval[0xa5] = "\xa5"; hexval[0xa6] = "\xa6"; hexval[0xa7] = "\xa7";
	hexval[0xa8] = "\xa8"; hexval[0xa9] = "\xa9"; hexval[0xaa] = "\xaa"; hexval[0xab] = "\xab";
	hexval[0xac] = "\xac"; hexval[0xad] = "\xad"; hexval[0xae] = "\xae"; hexval[0xaf] = "\xaf";
	hexval[0xb0] = "\xb0"; hexval[0xb1] = "\xb1"; hexval[0xb2] = "\xb2"; hexval[0xb3] = "\xb3";
	hexval[0xb4] = "\xb4"; hexval[0xb5] = "\xb5"; hexval[0xb6] = "\xb6"; hexval[0xb7] = "\xb7";
	hexval[0xb8] = "\xb8"; hexval[0xb9] = "\xb9"; hexval[0xba] = "\xba"; hexval[0xbb] = "\xbb";
	hexval[0xbc] = "\xbc"; hexval[0xbd] = "\xbd"; hexval[0xbe] = "\xbe"; hexval[0xbf] = "\xbf";
	hexval[0xc0] = "\xc0"; hexval[0xc1] = "\xc1"; hexval[0xc2] = "\xc2"; hexval[0xc3] = "\xc3";
	hexval[0xc4] = "\xc4"; hexval[0xc5] = "\xc5"; hexval[0xc6] = "\xc6"; hexval[0xc7] = "\xc7";
	hexval[0xc8] = "\xc8"; hexval[0xc9] = "\xc9"; hexval[0xca] = "\xca"; hexval[0xcb] = "\xcb";
	hexval[0xcc] = "\xcc"; hexval[0xcd] = "\xcd"; hexval[0xce] = "\xce"; hexval[0xcf] = "\xcf";
	hexval[0xd0] = "\xd0"; hexval[0xd1] = "\xd1"; hexval[0xd2] = "\xd2"; hexval[0xd3] = "\xd3";
	hexval[0xd4] = "\xd4"; hexval[0xd5] = "\xd5"; hexval[0xd6] = "\xd6"; hexval[0xd7] = "\xd7";
	hexval[0xd8] = "\xd8"; hexval[0xd9] = "\xd9"; hexval[0xda] = "\xda"; hexval[0xdb] = "\xdb";
	hexval[0xdc] = "\xdc"; hexval[0xdd] = "\xdd"; hexval[0xde] = "\xde"; hexval[0xdf] = "\xdf";
	hexval[0xe0] = "\xe0"; hexval[0xe1] = "\xe1"; hexval[0xe2] = "\xe2"; hexval[0xe3] = "\xe3";
	hexval[0xe4] = "\xe4"; hexval[0xe5] = "\xe5"; hexval[0xe6] = "\xe6"; hexval[0xe7] = "\xe7";
	hexval[0xe8] = "\xe8"; hexval[0xe9] = "\xe9"; hexval[0xea] = "\xea"; hexval[0xeb] = "\xeb";
	hexval[0xec] = "\xec"; hexval[0xed] = "\xed"; hexval[0xee] = "\xee"; hexval[0xef] = "\xef";
	hexval[0xf0] = "\xf0"; hexval[0xf1] = "\xf1"; hexval[0xf2] = "\xf2"; hexval[0xf3] = "\xf3";
	hexval[0xf4] = "\xf4"; hexval[0xf5] = "\xf5"; hexval[0xf6] = "\xf6"; hexval[0xf7] = "\xf7";
	hexval[0xf8] = "\xf8"; hexval[0xf9] = "\xf9"; hexval[0xfa] = "\xfa"; hexval[0xfb] = "\xfb";
	hexval[0xfc] = "\xfc"; hexval[0xfd] = "\xfd"; hexval[0xfe] = "\xfe"; hexval[0xff] = "\xff";
}

# urldecode function from Heiner Steven
# http://www.shelldorado.com/scripts/cmds/urldecode
func urldecode(text,    hex, i, hextab, decoded, len, c, c1, c2, code)
{
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
