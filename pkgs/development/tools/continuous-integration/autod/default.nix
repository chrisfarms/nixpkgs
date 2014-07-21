{ stdenv, lib, go, fetchgit }:

stdenv.mkDerivation rec {
  version = "0.1.0";
  name = "autod-${version}";

  phases = [ "buildPhase" ];

  src = fetchgit {
    url = "https://bitbucket.org/oxdi/autod.git";
    rev = "1a61229c5b9bd07edbb7901f8732f76ebc2f0c57";
    sha256 = "329958d69f3898e31ffaa90b8d3a61f836f3e4512222650b4c844c06b88fe378";
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
