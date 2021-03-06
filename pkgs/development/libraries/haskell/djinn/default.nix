{ cabal, haskeline, mtl }:

cabal.mkDerivation (self: {
  pname = "djinn";
  version = "2011.7.23";
  sha256 = "14748pqzrd1r9jg2vc9v232pi38q99l9zdlia6ashm2v871hp1xv";
  isLibrary = false;
  isExecutable = true;
  buildDepends = [ haskeline mtl ];
  preConfigure = self.stdenv.lib.optionalString self.stdenv.isDarwin ''
    sed -i 's/-Wall -optl-Wl/-Wall/' djinn.cabal
  '';
  meta = {
    homepage = "http://www.augustsson.net/Darcs/Djinn/";
    description = "Generate Haskell code from a type";
    license = self.stdenv.lib.licenses.bsd3;
    platforms = self.ghc.meta.platforms;
  };
})
