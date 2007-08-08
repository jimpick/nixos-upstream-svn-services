{ stdenv, gw6c, coreutils, procps, upstart, 
	gnused, iputils, gnugrep,
	username ? "",
	password ? "",
	server ? "anon.freenet6.net",
	keepAlive ? "30"
} :

stdenv.mkDerivation {
	name = "gw6c-service";
	scripts = ["=>/bin" ./control.in ];
	substFiles = ["=>/conf" ./gw6c.conf];
	inherit gw6c coreutils procps upstart 
		iputils gnused gnugrep;

	username = username;
	password = password;
	gw6server = server;
	keepAlive = keepAlive;
	authMethod = (if (username == "") then "anonymous" else "any");
	gw6dir = gw6c;

	builder = ./builder.sh;
}
