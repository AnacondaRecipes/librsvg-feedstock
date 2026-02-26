#!/bin/bash
set -exuo pipefail

# $BUILD_PREFIX needed here so gi-docgen can find .gir files:
export XDG_DATA_DIRS="${XDG_DATA_DIRS:+$XDG_DATA_DIRS:}$PREFIX/share:$BUILD_PREFIX/share"

# https://github.com/rust-lang/cargo/issues/10583#issuecomment-1129997984
export CARGO_NET_GIT_FETCH_WITH_CLI=true

meson_config_args=(
    -Dpixbuf=enabled
    -Dpixbuf-loader=enabled
    -Dintrospection=enabled
)

export PKG_CONFIG_PATH_FOR_BUILD=$BUILD_PREFIX/lib/pkgconfig
export PKG_CONFIG_PATH=$PKG_CONFIG_PATH:$BUILD_PREFIX/lib/pkgconfig

# call meson: enforce libdir=lib to avoid lib64 surprises
meson setup builddir \
  ${MESON_ARGS:-} \
  "${meson_config_args[@]}" \
  --prefix="$PREFIX" \
  -Dtests=false \
  -Dtriplet="${CARGO_BUILD_TARGET:-}" \
  -Dlocalstatedir="$PREFIX/var" \
  || { cat builddir/meson-logs/meson-log.txt 2>/dev/null || true; exit 1 ; }

ninja -C builddir -j"${CPU_COUNT:-1}" -v
ninja -C builddir install

# clean up docs to reduce package size (if you want docs as separate output, remove these)
rm -rf "$PREFIX/share/doc" || true
rm -rf "$PREFIX/share/gtk-doc" || true
