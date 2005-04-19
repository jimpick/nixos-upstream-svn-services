{stdenv, j2sdk, key, storepass}:

({ inherit storepass;
        store =
          stdenv.mkDerivation ({
            name    = "keystore";
            builder = ./keystore-builder.sh;
           inherit j2sdk storepass;
          } // key);
       } // key)
