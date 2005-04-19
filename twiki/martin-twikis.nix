rec {
  stwiki =
    twiki {
      name = "st-wiki";

      pubdir = "/home/martin/twiki/st/pub";
      datadir = "/home/martin/twiki/st/data";
      twikiName = "Software Technology Wiki";

      scriptUrlPath = "/twiki/st/bin";
      pubUrlPath = "/twiki/st/pub";
      twikiroot = "/home/martin/twiki/st/profiles/current";
    };

  stintrawiki =
    twiki {
      name = "st-intra-wiki";

      pubdir = "/home/martin/twiki/st-intra/pub";
      datadir = "/home/martin/twiki/st-intra/data";
      twikiName = "Software Technology Intra Wiki ";

      alwaysLogin = true;

      scriptUrlPath = "/twiki/st-intra/bin";
      pubUrlPath = "/twiki/st-intra/pub";
      twikiroot = "/home/martin/twiki/st-intra/profiles/current";
    };

  progtranswiki =
    twiki {
      name = "pt-wiki";

      pubdir = "/home/martin/twiki/pt/pub";
      datadir = "/home/martin/twiki/pt/data";
      twikiName = "Program Transformation Wiki";

      scriptUrlPath = "/twiki/pt/bin";
      pubUrlPath = "/twiki/pt/pub";
      twikiroot = "/home/martin/twiki/pt/profiles/current";
    };

  twiki = config :
    (import ./twiki-instance.nix).twiki ({
      defaultUrlHost = "http://127.0.0.1:8080";
      user = "martin";
      group = "users";
    } // config);
}
