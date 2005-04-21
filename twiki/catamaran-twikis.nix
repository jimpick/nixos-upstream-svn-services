rec {
  stwiki =
    twiki {
      name = "st-wiki";

      twikiroot = "/var/twiki/st/profiles/current";
      pubdir = "/var/twiki/st/pub";
      datadir = "/var/twiki/st/data";

      twikiName = "Software Technology Wiki";
      scriptUrlPath = "/twiki/st/bin";
      pubUrlPath = "/twiki/st/pub";
    };

  stintrawiki =
    twiki {
      name = "st-intra-wiki";

      twikiroot = "/var/twiki/st-intra/profiles/current";
      pubdir = "/var/twiki/st-intra/pub";
      datadir = "/var/twiki/st-intra/data";

      twikiName = "Software Technology Intra Wiki";
      scriptUrlPath = "/twiki/st-intra/bin";
      pubUrlPath = "/twiki/st-intra/pub";

      alwaysLogin = true;
    };

  progtranswiki =
    twiki {
      name = "pt-wiki";

      twikiroot = "/var/twiki/pt/profiles/current";
      pubdir = "/var/twiki/pt/pub";
      datadir = "/var/twiki/pt/data";

      twikiName = "Program Transformation Wiki";
      scriptUrlPath = "/twiki/pt/bin";
      pubUrlPath = "/twiki/pt/pub";
    };

  twiki = config :
    (import ./twiki-instance.nix).twiki ({
      defaultUrlHost = "http://catamaran.labs.cs.uu.nl";
      user = "apache";
      group = "daemon";
    } // config);
}
