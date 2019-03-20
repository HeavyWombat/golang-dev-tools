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

  while read -r DOWNLOAD_PKG INSTALL_PKG BINARY_NAME MODULE_MODE; do
    if [[ ! -d "$GOPATH/src/${DOWNLOAD_PKG}" ]]; then
      GO111MODULE="${MODULE_MODE}" go get -d "${DOWNLOAD_PKG}"
    fi

    echo -e "Building \\033[1m${INSTALL_PKG}\\033[0m for OS \\033[1;34m${OS}\\033[0m and architecture \\033[1;33m${ARCH}\\033[0m"
    (cd "${TARGET_PATH}" &&
      GO111MODULE="${MODULE_MODE}" GOOS="${OS}" GOARCH="${ARCH}" go build \
        -o "${BINARY_NAME}" \
        -tags netgo \
        -ldflags='-s -w -extldflags "-static"' \
        "${INSTALL_PKG}")

  done <<EOT
github.com/client9/misspell github.com/client9/misspell/cmd/misspell misspell auto
github.com/homeport/pina-golada/cmd/golada github.com/homeport/pina-golada/cmd/golada pina-golada on
honnef.co/go/tools/cmd/staticcheck honnef.co/go/tools/cmd/staticcheck staticcheck auto
github.com/fzipp/gocyclo github.com/fzipp/gocyclo gocyclo auto
github.com/modocache/gover github.com/modocache/gover gover auto
github.com/onsi/ginkgo/ginkgo github.com/onsi/ginkgo/ginkgo ginkgo auto
golang.org/x/lint/golint golang.org/x/lint/golint golint auto
EOT

  echo -e "Package binaries into tarball \\033[1;32m${OUTPUT_DIR}/golang-dev-tools-${OS}-${ARCH}.tar.gz\\033[0m"
  (cd "${TARGET_PATH}" && tar -cf - -- *) | gzip --best >"${OUTPUT_DIR}/golang-dev-tools-${OS}-${ARCH}.tar.gz"

  echo

done <<EOL
windows amd64
darwin amd64
linux amd64
freebsd amd64
EOL
