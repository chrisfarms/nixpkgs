{ stdenv, fetchurl, zlib, ncurses, readline, libossp_uuid }:

let version = "8.2.23"; in

stdenv.mkDerivation rec {
  name = "postgresql-${version}";

  src = fetchurl {
    url = "mirror://postgresql/source/v${version}/${name}.tar.bz2";
    sha256 = "1lgj74q0xlira6sj93wpavyjj5dr622x0r54k3pykb78jirsrhjn";
  };

  buildInputs = [ zlib ncurses readline libossp_uuid ];

  postBuild =
	''
	(cd contrib && make)
	'';

  postInstall =
	''
	(cd contrib && make install)
	'';

  LC_ALL = "C";

  patches = [ ./less-is-more.patch ];

  passthru = { inherit readline; };

  meta = {
    homepage = http://www.postgresql.org/;
    description = "A powerful, open source object-relational database system";
    license = "bsd";
    maintainers = [ stdenv.lib.maintainers.ocharles ];
    hydraPlatforms = stdenv.lib.platforms.linux;
  };
}
