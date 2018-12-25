#!/usr/bin/env bash

# Copyright © 2018 Matthias Diester
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

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

  for PKGPATH in \
    github.com/client9/misspell/cmd/misspell \
    github.com/fzipp/gocyclo \
    github.com/modocache/gover \
    github.com/onsi/ginkgo/ginkgo \
    golang.org/x/lint/golint \
    honnef.co/go/tools/cmd/megacheck; do

    if [[ ! -d "$GOPATH/src/${PKGPATH}" ]]; then
      go get -d "${PKGPATH}"
    fi

    VERSION=$(cd "$GOPATH/src/${PKGPATH}" && (git describe --tags 2>/dev/null || git rev-parse HEAD | cut -c-8))

    echo -e "Compiling \\033[1m${PKGPATH}\\033[0m version \\033[1;3m${VERSION}\\033[0m for OS \\033[1;34m${OS}\\033[0m and architecture \\033[1;33m${ARCH}\\033[0m"
    (cd "${TARGET_PATH}" && GOOS="$OS" GOARCH="$ARCH" go build -tags netgo -ldflags='-s -w -extldflags "-static"' "${PKGPATH}")

  done

  echo -e "Package binaries into tarball \\033[1;32m${OUTPUT_DIR}/golang-dev-tools-${OS}-${ARCH}.tar.gz\\033[0m"
  (cd "${TARGET_PATH}" && tar -cf - -- *) | gzip --best >"${OUTPUT_DIR}/golang-dev-tools-${OS}-${ARCH}.tar.gz"

  echo

done <<EOL
windows amd64
darwin amd64
linux amd64
freebsd amd64
EOL
