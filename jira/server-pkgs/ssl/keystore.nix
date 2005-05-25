{stdenv, j2re, key, storepass}:

({ inherit storepass;
        store =
          stdenv.mkDerivation ({
            name    = "keystore";
            builder = ./keystore-builder.sh;
           inherit j2re storepass;
          } // key);
       } // key)
