#!/bin/bash

set -eux

. .github/scripts/env.sh
. .github/scripts/common.sh

# ensure ghcup
if ! command -v ghcup ; then
	install_ghcup
fi

# create tarball/zip
case "${TARBALL_EXT}" in
    zip)
		HLS_VERSION="$(grep '^version:' haskell-language-server.cabal | awk '{ print $2 }')"
		(
			cd "$CI_PROJECT_DIR/out/${ARTIFACT}"
			zip "$CI_PROJECT_DIR/out/haskell-language-server-${HLS_VERSION}-${ARTIFACT}.zip" haskell-language-server-*
		)
        ;;
    tar.xz)
		GHCS="$(cd "$CI_PROJECT_DIR/out/${ARTIFACT}" && rm -f ./*.json && for ghc in * ; do printf "%s " "$ghc" ; done)"
		emake --version
		emake GHCUP=ghcup ARTIFACT="${ARTIFACT}" GHCS="${GHCS}" bindist
		emake GHCUP=ghcup ARTIFACT="${ARTIFACT}"                bindist-tar
		emake GHCUP=ghcup                        GHCS="${GHCS}" clean-ghcs
        ;;
    *)
        fail "Unknown TARBALL_EXT: ${TARBALL_EXT}"
        ;;
esac
