{ pkgs, ... }:

# Code took from:
# https://www.alecjacobson.com/weblog/3816.html
# https://gist.github.com/mwender/49609a18be41b45b2ae4

pkgs.runCommand "impbcopy-1.0.0"
  {
    __noChroot = pkgs.stdenv.isDarwin;
  }
  ''
    cp ${./impbcopy.m} impbcopy.m

    /usr/bin/gcc -Wall -g -O3 -ObjC \
      -framework Foundation \
      -framework AppKit \
      -o impbcopy impbcopy.m

    mkdir -p $out/bin
    cp impbcopy $out/bin/impbcopy
  ''
