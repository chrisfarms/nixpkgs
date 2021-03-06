{ cabal, cereal, chell, chellQuickcheck, filepath, libxmlSax
, network, parsec, QuickCheck, random, text, transformers, vector
, xmlTypes
}:

cabal.mkDerivation (self: {
  pname = "dbus";
  version = "0.10.8";
  sha256 = "1pqcb6fk6l2xzwyy3n9sa2q2k3qykym1f98n2zf75545ix46b1r6";
  buildDepends = [
    cereal libxmlSax network parsec random text transformers vector
    xmlTypes
  ];
  testDepends = [
    cereal chell chellQuickcheck filepath libxmlSax network parsec
    QuickCheck random text transformers vector xmlTypes
  ];
  jailbreak = true;
  doCheck = false;
  meta = {
    homepage = "https://john-millikin.com/software/haskell-dbus/";
    description = "A client library for the D-Bus IPC system";
    license = self.stdenv.lib.licenses.gpl3;
    platforms = self.ghc.meta.platforms;
  };
})
