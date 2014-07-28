{
  stdenv
, go
, spidermonkey_185
, fetchgit
}: 
let 
  go-flags = fetchgit {
    url = "https://github.com/jessevdk/go-flags";
    rev = "df6c2fabb4d17f378e2ff6fa08cc212ee3e689f1";
    sha256 = "e3efac06ef5f9fabd19e8da6e2f4cf0dff358fc3c9f46c998df968b3c876eb35";
  };
  go-monkey = fetchgit {
    url = "https://github.com/chrisfarms/monkey";
    rev = "818b8caec8570c1c32ba241f7574badc46aa9793";
    sha256 = "137c2fcf6e0d391536173deb3b8f12bb159313c4e99c4842898f888484773ccf";
  };
  go-pq = fetchgit {
    url = "https://github.com/lib/pq";
    rev = "1abc04666264e3f3b6c0907c92420789e72d987a";
    sha256 = "08f8afedc030ffdeebdd1562aeae54882ce0bda78fef7bde9621d7b33911e0f7";
  };
  go-req = fetchgit {
    url = "https://github.com/franela/goreq";
    rev = "79ca58ab93a78e3cf4d2fd6133d8497af7c48b28";
    sha256 = "0daa6701fbe51ca765d166a6e99fc3c3a1893f8451e27032b7dfd89d804e2902";
  };
in stdenv.mkDerivation rec {
  version = "2.0.0";
  name = "cyclerack";
  
  src = ../../../../sources/cycle-rack;

  buildInputs = [ go spidermonkey_185 ];

  preBuild = ''
    export HOME="$PWD"

    mkdir -p src/github.com/jessevdk/go-flags/
    ln -s ${go-flags}/* src/github.com/jessevdk/go-flags/

    mkdir -p src/github.com/chrisfarms/monkey
    ln -s ${go-monkey}/* src/github.com/chrisfarms/monkey

    mkdir -p src/github.com/lib/pq
    ln -s ${go-pq}/* src/github.com/lib/pq

    mkdir -p src/github.com/franela/goreq
    ln -s ${go-req}/* src/github.com/franela/goreq

    # don't download dependencies as we already have them
    sed -i '/go get/d' Makefile
  '';

  installPhase = ''
    ensureDir $out/bin
    make
    cp bin/server $out/bin/cycle-rack
  '';

  meta = with stdenv.lib; {
    description = "HTTP server for hosting server-side javascript web applications";
    homepage = https://bitbucket.org/oxdi/cycle-rack;
    license = "GPL";
    maintainers = with maintainers; [ "Chris Farmiloe <chris@oxdi.eu>" ];
    platforms = stdenv.lib.platforms.linux;
  };
}
