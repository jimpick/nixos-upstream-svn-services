{ stdenv, ircdHybrid, coreutils, su,
	iproute, gnugrep,
	 gw6cEnabled,
	serverName ? "hades.arpa", 
	sid ? "0NL",
	description ? "Hybrid-7",
	rsaKey ? null,
	certificate ? null,
	adminEmail ? "null@example.com",
	extraIPs ? [],
	extraPort ? "2211"
} :

assert (certificate != null) -> (rsaKey != null);

stdenv.mkDerivation {
	name = "ircd-hybrid-service";
	scripts = ["=>/bin" ./control.in ];
	substFiles = ["=>/conf" ./ircd.conf];
	inherit ircdHybrid coreutils su
		iproute gnugrep;

	gw6cEnabled = if gw6cEnabled then 
		"true" else "false";

	inherit serverName sid description adminEmail
		extraPort;

	cryptoSettings = "" +
		(if rsaKey != null then 
		"rsa_private_key_file = \""+
	rsaKey+"\";
	" else "") +
		(if certificate != null then 
		" ssl_certificate_file = \""+
	certificate+"\";
	" else "") ;

	extraListen = map (ip:"host = \""+ip+"\";
	port = 6665 .. 6669, "+extraPort+"; ") extraIPs;

	builder = ./builder.sh;
}
