let {
  pkgs =
    import ./pkgs/system/i686-linux.nix;

  body =
    (import ./server-pkgs/postgresql/cluster.nix) {
      inherit (pkgs) stdenv postgresql;
      port    = (import ./database-account.nix).port;
      serveruser = (import ./database-account.nix).username;
      logdir  = "/home/eelco/postgres/logs";
      datadir = "/home/eelco/postgres/jira-data-1";
    };
}
