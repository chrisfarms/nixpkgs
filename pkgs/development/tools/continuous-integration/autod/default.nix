{ stdenv, lib, go, fetchgit }:

stdenv.mkDerivation rec {
  version = "0.1.0";
  name = "autod-${version}";

  phases = [ "buildPhase" ];

  src = fetchgit {
    url = "https://bitbucket.org/oxdi/autod.git";
    rev = "132e906eb2243aea16a65e47bcb285a270c60225";
    sha256 = "0698ae22aaf267aff28384ab0bd9e9303a3831aa4faee3f94d179974c91eb0d5";
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
