{ stdenv, lib, go, fetchgit }:

stdenv.mkDerivation rec {
  version = "0.1.0";
  name = "autod-${version}";

  phases = [ "buildPhase" ];

  src = fetchgit {
    url = "https://bitbucket.org/oxdi/autod.git";
    rev = "12a05f4526fe274ea204c5d0153e11a40cf0262c";
    sha256 = "ce85fd99632adcf06234c7e6e3609c785892f081fc8458929b5e02f3e8d9c157";
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
