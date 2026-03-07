{
  lib,
  stdenvNoCC,
  secrets,
  unzip,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "berkeley-mono";
  version = "2.003";

  src = "${secrets}/fonts/BerkeleyMono.zip";

  outputs = [ "out" ];

  nativeBuildInputs = [
    unzip
  ];

  unpackPhase = ''
    unzip "$src"
  '';

  installPhase = ''
    runHook preInstall

    pushd */TX-02-*/
    install -D -m444 -t $out/share/fonts/opentype *.otf

    runHook postInstall
  '';

  meta = {
    description = "Berkeley Mono™ Typeface";
    homepage = "https://usgraphics.com/products/berkeley-mono";
    license = lib.licenses.unfree;
    platforms = lib.platforms.all;
  };
})
