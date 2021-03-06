{ cabal }:

cabal.mkDerivation (self: {
  pname = "bv";
  version = "0.2.2";
  sha256 = "0d5hscjakp7dwifa4l8xikyip45y402kf9pbmpfmmnybja23zhg0";
  isLibrary = true;
  isExecutable = true;
  meta = {
    homepage = "http://bitbucket.org/iago/bv-haskell";
    description = "Bit-vector arithmetic library";
    license = self.stdenv.lib.licenses.bsd3;
    platforms = self.ghc.meta.platforms;
  };
})
