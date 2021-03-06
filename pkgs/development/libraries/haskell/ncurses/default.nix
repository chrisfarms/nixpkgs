{ cabal, c2hs, ncurses, text, transformers }:

cabal.mkDerivation (self: {
  pname = "ncurses";
  version = "0.2.10";
  sha256 = "0qdw5dwi1w42nygvzyq8la7i917f0fz9qjw6ivgl2h1rjxc5j9cb";
  buildDepends = [ text transformers ];
  buildTools = [ c2hs ];
  extraLibraries = [ ncurses ];
  patchPhase = "find . -type f -exec sed -i -e 's|ncursesw/||' {} \\;";
  meta = {
    homepage = "https://john-millikin.com/software/haskell-ncurses/";
    description = "Modernised bindings to GNU ncurses";
    license = self.stdenv.lib.licenses.gpl3;
    platforms = self.ghc.meta.platforms;
  };
})
