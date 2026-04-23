{
  lib,
  stdenv,
  fetchzip,
}:

stdenv.mkDerivation rec {
  pname = "commit-mono-nf";
  version = "1.143";

  src = fetchzip {
    url = "https://github.com/BirkhoffLee/CommitMono-Customized-NF/releases/download/v${version}/CommitMono.Nerd.Font.zip";
    sha256 = "sha256-ihnN1sbL8Nb4ks7D55Zsbwq+CiNSqCMX6UCIT7CkvGA=";
    stripRoot = false;
  };

  installPhase = ''
    mkdir -p $out/share/fonts/opentype
    find . -type f -name '*.otf' -exec cp -v {} $out/share/fonts/opentype/ \;
  '';

  meta = {
    description = "CommitMono Customized Nerd Font";
    homepage = "https://github.com/BirkhoffLee/CommitMono-Customized-NF";
    license = lib.licenses.ofl;
    platforms = lib.platforms.all;
  };
}
