x@{builderDefsPackage
  , mesa, SDL, scons, SDL_ttf, SDL_image, zlib, SDL_net, speex, libvorbis
  , libogg, boost, fribidi, bsdiff
  , ...}:
builderDefsPackage
(a :  
let 
  helperArgNames = ["stdenv" "fetchurl" "builderDefsPackage"] ++ 
    [];

  buildInputs = map (n: builtins.getAttr n x)
    (builtins.attrNames (builtins.removeAttrs x helperArgNames));
  sourceInfo = rec {
   baseName="glob2";
    version="0.9.4";
    patchlevel="4";
    name="${baseName}-${version}.${patchlevel}";
    url="mirror://savannah/glob2/${version}/${name}.tar.gz";
    hash="1f0l2cqp2g3llhr9jl6jj15k0wb5q8n29vqj99xy4p5hqs78jk8g";
  };
in
rec {
  src = a.fetchurl {
    url = sourceInfo.url;
    sha256 = sourceInfo.hash;
  };

  tutorial4patch = a.fetchurl {
    url = "http://bugs.debian.org/cgi-bin/bugreport.cgi?msg=34;filename=tutorial-part4.map.bspatch;att=1;bug=595448";
    name = "globulation2-tutorial4-map-patch-debian.bspatch";
    sha256 = "d3511ac0f822d512c42abd34b3122f2990862d3d0af6ce464ff372f5bd7f35e9";
  };

  inherit (sourceInfo) name version;
  inherit buildInputs;

  /* doConfigure should be removed if not needed */
  phaseNames = ["doUnpack" "doPatch" "doBspatch" "workaroundScons" "doScons"];

  patches = [./header-order.patch];

  doBspatch = a.fullDepEntry ''
    cp campaigns/tutorial-part4.map{,.orig}
    bspatch  campaigns/tutorial-part4.map{.orig,} ${tutorial4patch}
  '' ["minInit" "doUnpack" "addInputs"];

  # FIXME
  # I officially fail to understand what goes on, but that seems to work
  # too well not to use. Yes, it is ugly, I know...
  workaroundScons = a.fullDepEntry ''
    echo '#! ${a.stdenv.shell}' >> o
    echo 'g++ -o "$@"' >> o
    chmod a+x o
    export PATH="$PATH:$PWD"
  '' ["minInit"];

  sconsFlags = [
    "DATADIR=$out/share/globulation2/glob2"
    "BINDIR=$out/bin"
    "INSTALLDIR=$out/share/globulation2"
  ];
      
  meta = {
    description = "RTS without micromanagement";
    maintainers = with a.lib.maintainers;
    [
      raskin
    ];
    platforms = with a.lib.platforms;
      linux;
    license = a.lib.licenses.gpl3;
  };
  passthru = {
    updateInfo = {
      downloadPage = "http://globulation2.org/wiki/Download_and_Install";
    };
  };
}) x

