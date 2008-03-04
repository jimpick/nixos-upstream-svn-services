{ stdenv, gw6c, coreutils, procps, upstart, 
	gnused, iputils, gnugrep,
	writeScript, seccureUser,
	username ? "",
	password ? "",
	server ? "anon.freenet6.net",
	keepAlive ? "30",
	everPing ? "1000000"
} :

stdenv.mkDerivation {
	name = "gw6c-service";
	inherit gw6c coreutils procps upstart 
		iputils gnused gnugrep 
		seccureUser;

	username = username;
	password = password;
	gw6server = server;
	keepAlive = keepAlive;
	inherit everPing;
	authMethod = (if (username == "") then "anonymous" else "any");
	gw6dir = gw6c;

	builder = ./builder.sh;

	controlScript = ./control.in;
	confFile = ./gw6c.conf;
}
