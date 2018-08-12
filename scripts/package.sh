#!/bin/bash

set -euo pipefail

OUTPUT_DIR="$1"
BASEDIR="$(cd "$(dirname "$0")/.." && pwd)"

if [[ ! -d ${OUTPUT_DIR} ]]; then
  mkdir -p "${OUTPUT_DIR}"
fi

# Compile all possible operating systems and architectures into the binaries directory (to be used for distribution)
while read -r OS ARCH; do
  TARGET_PATH="${BASEDIR}/binaries/${OS}-${ARCH}"
  mkdir -p "$TARGET_PATH"

  while read -r BINARY PKGPATH; do
    VERSION=$(cd "$GOPATH/src/${PKGPATH}" && (git describe --tags 2>/dev/null || git rev-parse HEAD | cut -c1-8))
    TARGET_FILE="${TARGET_PATH}/${BINARY}"

    echo -e "Compiling \\033[1m${BINARY}\\033[0m version \\033[1;3m${VERSION}\\033[0m for OS \\033[1;34m${OS}\\033[0m and architecture \\033[1;33m${ARCH}\\033[0m"
    GOOS="$OS" GOARCH="$ARCH" go build -ldflags="-s -w" -o "$TARGET_FILE" "${PKGPATH}"

  done <<EOB
golint     golang.org/x/lint/golint
gocyclo    github.com/fzipp/gocyclo
megacheck  honnef.co/go/tools/cmd/megacheck
misspell   github.com/client9/misspell/cmd/misspell
shfmt      mvdan.cc/sh/cmd/shfmt
EOB

  tar -cf - -C "${TARGET_PATH}" golint gocyclo megacheck misspell shfmt | gzip --best >"${OUTPUT_DIR}/golang-dev-tools-${OS}-${ARCH}.tar.gz"

done <<EOL
darwin	 amd64
freebsd	 amd64
linux	   amd64
EOL
