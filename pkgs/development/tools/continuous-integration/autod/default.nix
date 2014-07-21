{ stdenv, lib, go, fetchgit }:

stdenv.mkDerivation rec {
  version = "0.1.0";
  name = "autod-${version}";

  phases = [ "buildPhase" ];

  src = fetchgit {
    url = "https://bitbucket.org/oxdi/autod.git";
    rev = "fc5ca1fd056328f932634c24e2a900f8d222939b";
    sha256 = "17a89bfbe654a2edff41b9792b726f45efe0aed48623267c9fbb0714c5c78627";
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
