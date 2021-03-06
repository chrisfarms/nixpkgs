{ cabal, HUnit, QuickCheck }:

cabal.mkDerivation (self: {
  pname = "quickcheck-io";
  version = "0.1.1";
  sha256 = "16q3sqvxnaqmbb1zbda8f61mdlmmzxhrznqxab113lmg380nwfm2";
  buildDepends = [ HUnit QuickCheck ];
  meta = {
    description = "Use HUnit assertions as QuickCheck properties";
    license = self.stdenv.lib.licenses.mit;
    platforms = self.ghc.meta.platforms;
  };
})
