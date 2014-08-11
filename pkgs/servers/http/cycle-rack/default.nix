{
  stdenv
, fetchgit
, go_1_3 
, pkgconfig
, autoconf213
, perl
, python
, zip
, git 
}: 
let 
  go-flags = fetchgit {
    url = "https://github.com/jessevdk/go-flags";
    rev = "df6c2fabb4d17f378e2ff6fa08cc212ee3e689f1";
    sha256 = "e3efac06ef5f9fabd19e8da6e2f4cf0dff358fc3c9f46c998df968b3c876eb35";
  };
  go-jsapi = fetchgit {
    url = "https://github.com/chrisfarms/jsapi";
    rev = "97168e174bd47b727e3702569d59f99279c20533";
    sha256 = "d83263beff3995e26f004e96c6bb68f01fcc965609a4dab2db607521017ab812";
  };
  go-linenoise = fetchgit {
    url = "https://github.com/GeertJohan/go.linenoise";
    rev = "34971d981fb78adbdc102963d934f3c1b2e6ea4c";
    sha256 = "d5080b2fa0bccbaf935c53a6ac37e89bdfcac0af1ab4b5d65d7da5b5c258f887";
  };
  mozsrc = fetchgit {
    url = "https://github.com/mozilla/gecko-dev.git";
    rev = "0ec002deb3134e52ca13bf3081d775f06ee3b62f";
    sha256 = "c0f8228a7a50b8fd84dcefe8d1d17998871161529c952f2fd0e925f7e9b68a89";
  };
  mozjs = stdenv.mkDerivation {
    name = "mozjs";
    src = mozsrc;
    buildInputs = [
      pkgconfig
      autoconf213
      perl
      python
      zip
      git 
    ];
    buildPhase = ''
      ensureDir $out
      cp -r . $out
      cd $out/js/src
      autoconf
      mkdir -p build-release
      cd build-release
      ../configure --prefix=$out --disable-shared-js --enable-nspr-build --enable-debug
      make
    '';
    installPhase = ''
      # noop
    '';
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
  version = "2.0.3";
  name = "cyclerack-${version}";
  
  src = ../../../../sources/cycle-rack;

  buildInputs = [ 
    go_1_3 
  ];

  buildPhase = ''
    export HOME="$PWD"
    export GOPATH=$PWD

    mkdir -p src/github.com/jessevdk/go-flags/
    ln -s ${go-flags}/* src/github.com/jessevdk/go-flags/

    mkdir -p src/github.com/GeertJohan/go.linenoise
    ln -s ${go-linenoise}/* src/github.com/GeertJohan/go.linenoise

    mkdir -p src/github.com/lib/pq
    ln -s ${go-pq}/* src/github.com/lib/pq

    mkdir -p src/github.com/franela/goreq
    ln -s ${go-req}/* src/github.com/franela/goreq

    mkdir -p src/github.com/chrisfarms/jsapi
    cp -r ${go-jsapi}/* src/github.com/chrisfarms/jsapi/
    chmod -R +w src/github.com/chrisfarms/jsapi/
    rm -rf src/github.com/chrisfarms/jsapi/lib/moz
    mkdir -p src/github.com/chrisfarms/jsapi/lib/moz
    ln -s ${mozjs}/* src/github.com/chrisfarms/jsapi/lib/moz
    chmod -R +w src/github.com/chrisfarms/jsapi/lib
    ( cd src/github.com/chrisfarms/jsapi/ && (
      cd lib &&
      cp "$(readlink -f moz/js/src/build-release/dist/lib/libjs_static.a)" ./libjs.a &&
      rm -f libjsapi.a &&
      g++ -fPIC -c -std=c++11 -pthread -pipe -Wno-write-strings \
      -Wno-invalid-offsetof \
      -include ${mozjs}/js/src/build-release/dist/include/js/RequiredDefines.h \
      -pthread \
      -include ${mozjs}/js/src/build-release/js/src/js-confdefs.h \
      -I${mozjs}/js/src/build-release/dist/include \
      -I${mozjs}/js/src \
      -I${mozjs}/js/src/build-release/dist/include/nspr \
      -o jsapi.o js.cpp &&
      ar crv libjsapi.a jsapi.o
    ) && go build)

    # don't download dependencies as we already have them
    sed -i '/go get/d' Makefile
  '';

  installPhase = ''
    ensureDir $out/bin
    export GOPATH=$PWD
    rm -f bin/server
    (cd src/github.com/chrisfarms/jsapi && go install server)
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
