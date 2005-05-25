let {
  pkgs =
    import ./pkgs/system/i686-linux.nix;

  body =
    (import ./server-pkgs/postgresql/cluster.nix) {
      inherit (pkgs) stdenv postgresql;
      port    = (import ./database-account.nix).port;
      serveruser = "postgres";
      logdir  = "/home/postgres/logs";
      datadir = "/home/postgres/jira-data-3";
    };
}
