{ stdenv, lib, go, fetchgit }:

stdenv.mkDerivation rec {
  version = "0.1.0";
  name = "autod-${version}";

  phases = [ "buildPhase" ];

  src = fetchgit {
    url = "https://bitbucket.org/oxdi/autod.git";
    rev = "e37c0c33d087c4781f6dd63aaa4030d22fb678d6";
    sha256 = "e806f86f4f74d744d5bd15811535555c1d2456d363ae3dc7188c742b769b23ff";
  };

  buildInputs = [ go ];

  buildPhase = ''
    export GOPATH=$src
    ensureDir $out/bin
    (cd $src && go build -o $out/bin/autod)
  '';

  meta = with stdenv.lib; {
    description = "Continuous deployment tool";
    homepage = http://bitbucket.org/oxdi/autod;
    license = licenses.asl20;
    platforms = platforms.unix;
  };
}
