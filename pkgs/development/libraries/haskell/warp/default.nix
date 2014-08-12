# This file was auto-generated by cabal2nix. Please do NOT edit manually!

{ cabal, async, autoUpdate, blazeBuilder, caseInsensitive, doctest
, hashable, hspec, HTTP, httpDate, httpTypes, HUnit, liftedBase
, network, QuickCheck, simpleSendfile, streamingCommons, text, time
, transformers, unixCompat, void, wai
}:

cabal.mkDerivation (self: {
  pname = "warp";
  version = "3.0.0.6";
  sha256 = "0085v0gnjr4yv4s341jyc8cf9l69rmj9rrnr6h2lyhq5hx1i1lw8";
  buildDepends = [
    autoUpdate blazeBuilder caseInsensitive hashable httpDate httpTypes
    network simpleSendfile streamingCommons text unixCompat void wai
  ];
  testDepends = [
    async autoUpdate blazeBuilder caseInsensitive doctest hashable
    hspec HTTP httpDate httpTypes HUnit liftedBase network QuickCheck
    simpleSendfile streamingCommons text time transformers unixCompat
    void wai
  ];
  doCheck = false;
  meta = {
    homepage = "http://github.com/yesodweb/wai";
    description = "A fast, light-weight web server for WAI applications";
    license = self.stdenv.lib.licenses.mit;
    platforms = self.ghc.meta.platforms;
  };
})
