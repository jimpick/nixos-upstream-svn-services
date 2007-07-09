{ stdenv, gw6c, coreutils, procps, upstart, nettools,
	username ? "",
	password ? "",
	server ? "anon.freenet6.net"
} :

stdenv.mkDerivation {
	name = "gw6c-service";
	scripts = ["=>/bin" ./control.in ];
	substFiles = ["=>/conf" ./gw6c.conf];
	inherit gw6c coreutils procps upstart 
		nettools;

	username = username;
	password = password;
	gw6server = server;
	authMethod = (if (username == "") then "anonymous" else "any");
	gw6dir = gw6c;

	builder = ./builder.sh;
}
