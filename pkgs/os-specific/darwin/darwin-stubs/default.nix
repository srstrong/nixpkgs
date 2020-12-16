{ stdenv, fetchurl }:

stdenv.mkDerivation {
  pname = "darwin-stubs";
  version = "10.12";

  src = fetchurl {
    url = "https://s3.ap-northeast-1.amazonaws.com/nix-misc.cons.org.nz/stubs-10.12-4ea7110d947803a4a2dec334a630587fe049a7b5.tar.gz";
    sha256 = "1fyd3xig7brkzlzp0ql7vyfj5sp8iy56kgp548mvicqdyw92adgm";
  };

  dontBuild = true;

  installPhase = ''
    mkdir $out
    mv * $out
  '';
}
