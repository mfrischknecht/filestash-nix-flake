self: { nixpkgs }:

let
  version = "b9a177aa2662f082a4c42b001b76ec8e4856df2d";

in with import nixpkgs { system = "x86_64-linux"; };

stdenv.mkDerivation {
  name = "filestash";

  src = fetchgit {
    url = "https://github.com/mickael-kerjean/filestash";
    rev = "${version}";
    sha256 = "uzcwZ56ESdQE4euI1tZtBoqD9sFZ7e/CKbMNV+WERc4=";
    leaveDotGit = true;
  };

  patches = [
    ./no-pkg-config-reset.patch
    ./link-deps-as-shared-libraries.patch

    # Temporarily necessary:
    ./update-go-sqlite3.patch # The vendored version triggers https://github.com/mattn/go-sqlite3/issues/1014
  ];

  nativeBuildInputs = with nixpkgs; [
    git
    gcc gnumake pkg-config
    nodejs
    go
  ];

  buildInputs = with nixpkgs; with xorg; [
    glibc glib vips libSM libX11 libXext bzip2 libexif expat
    fftw fontconfig freetype giflib gomp libgsf harfbuzz icu
    jbigkit libjpeg lcms2 libtool lzma orc pango pcre pixman
    libpng poppler libraw rt libtiff libxcb zlib
  ];

  buildPhase = with nixpkgs; with xorg; ''
    (
      cd server/plugin/plg_image_light/deps
      gcc -Wall -c src/libresize.c `pkg-config --cflags glib-2.0`
      ar rcs libresize_linux_amd64.a libresize.o
    )

    (
      cd server/plugin/plg_image_light/deps
      gcc -Wall -c src/libtranscode.c
      ar rcs libtranscode_linux_amd64.a libtranscode.o

      echo
      pwd
      ls -ltrash

      echo
      echo nm libresize_linux_amd64.a
      nm libresize_linux_amd64.a

      echo
      echo nm libtranscode_linux_amd64.a
      nm libtranscode_linux_amd64.a
    )

    mkdir go_cache;
    export GOCACHE="$(pwd)/go_cache";

    # CGO_LDFLAGS="$CGO_LDFLAGS -L${glibc.out}/lib"
    # CGO_LDFLAGS="$CGO_LDFLAGS -L${glib.out}/lib"
    # CGO_LDFLAGS="$CGO_LDFLAGS -L${vips.out}/lib"
    # CGO_LDFLAGS="$CGO_LDFLAGS -L${libSM.out}/lib"
    # CGO_LDFLAGS="$CGO_LDFLAGS -L${libX11.out}/lib"
    # CGO_LDFLAGS="$CGO_LDFLAGS -L${libXext.out}/lib"
    # CGO_LDFLAGS="$CGO_LDFLAGS -L${bzip2.out}/lib"
    # CGO_LDFLAGS="$CGO_LDFLAGS -L${libexif.out}/lib"
    # CGO_LDFLAGS="$CGO_LDFLAGS -L${expat.out}/lib"
    # CGO_LDFLAGS="$CGO_LDFLAGS -L${fftw.out}/lib"
    # CGO_LDFLAGS="$CGO_LDFLAGS -L${fontconfig.out}/lib"
    # CGO_LDFLAGS="$CGO_LDFLAGS -L${freetype.out}/lib"
    # CGO_LDFLAGS="$CGO_LDFLAGS -L${giflib.out}/lib"
    # CGO_LDFLAGS="$CGO_LDFLAGS -L${gomp.out}/lib"
    # CGO_LDFLAGS="$CGO_LDFLAGS -L${libgsf.out}/lib"
    # CGO_LDFLAGS="$CGO_LDFLAGS -L${harfbuzz.out}/lib"
    # CGO_LDFLAGS="$CGO_LDFLAGS -L${icu.out}/lib"
    # CGO_LDFLAGS="$CGO_LDFLAGS -L${jbigkit.out}/lib"
    # CGO_LDFLAGS="$CGO_LDFLAGS -L${libjpeg.out}/lib"
    # CGO_LDFLAGS="$CGO_LDFLAGS -L${lcms2.out}/lib"
    # CGO_LDFLAGS="$CGO_LDFLAGS -L${libtool.out}/lib"
    # CGO_LDFLAGS="$CGO_LDFLAGS -L${lzma.out}/lib"
    # CGO_LDFLAGS="$CGO_LDFLAGS -L${orc.out}/lib"
    # CGO_LDFLAGS="$CGO_LDFLAGS -L${pango.out}/lib"
    # CGO_LDFLAGS="$CGO_LDFLAGS -L${pcre.out}/lib"
    # CGO_LDFLAGS="$CGO_LDFLAGS -L${pixman.out}/lib"
    # CGO_LDFLAGS="$CGO_LDFLAGS -L${libpng.out}/lib"
    # CGO_LDFLAGS="$CGO_LDFLAGS -L${poppler.out}/lib"
    # CGO_LDFLAGS="$CGO_LDFLAGS -L${libraw.out}/lib"
    # CGO_LDFLAGS="$CGO_LDFLAGS -L${rt.out}/lib"
    # CGO_LDFLAGS="$CGO_LDFLAGS -L${libtiff.out}/lib"
    # CGO_LDFLAGS="$CGO_LDFLAGS -L${libxcb.out}/lib"
    # CGO_LDFLAGS="$CGO_LDFLAGS -L${zlib.out}/lib"
    # CGO_LDFLAGS="$CGO_LDFLAGS -lvips"
    # export CGO_LDFLAGS="$CGO_LDFLAGS"

    make
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp ./dist/filestash $out/bin
  '';
}

# vim: set ts=2 sw=2 tw=0 et :
