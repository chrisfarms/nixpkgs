{ cabal, dbus }:

cabal.mkDerivation (self: {
  pname = "fdo-notify";
  version = "0.3.1";
  sha256 = "1n4zk1i7g34w0wk5zy8n4r63xbglxf62h8j78kv5fc2yn95l30vh";
  buildDepends = [ dbus ];
  meta = {
    homepage = "http://bitbucket.org/taejo/fdo-notify/";
    description = "Desktop Notifications client";
    license = self.stdenv.lib.licenses.bsd3;
    platforms = self.ghc.meta.platforms;
  };
})
