{ cabal, syb }:

cabal.mkDerivation (self: {
  pname = "instant-generics";
  version = "0.4";
  sha256 = "14z6135jvmry9b52p21cqnwgp2w0g6frh1fm7z5byph06xls9r7l";
  buildDepends = [ syb ];
  meta = {
    homepage = "http://www.cs.uu.nl/wiki/GenericProgramming/InstantGenerics";
    description = "Generic programming library with a sum of products view";
    license = self.stdenv.lib.licenses.bsd3;
    platforms = self.ghc.meta.platforms;
    maintainers = [ self.stdenv.lib.maintainers.andres ];
  };
})
