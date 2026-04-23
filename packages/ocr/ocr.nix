{ pkgs, ... }:

pkgs.runCommand "ocr-1.0.0"
  {
    # Disable sandbox to access Xcode/Swift tools on macOS
    __noChroot = pkgs.stdenv.isDarwin;
  }
  ''
    # Copy source file to build directory
    cp ${./ocr.swift} ocr.swift

    # Compile with Swift (frameworks auto-linked from imports)
    /usr/bin/xcrun swiftc ocr.swift -o ocr -O

    # Install binary
    mkdir -p $out/bin
    cp ocr $out/bin/ocr
  ''
