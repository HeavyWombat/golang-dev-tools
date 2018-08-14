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

all: go-get

.PHONY: clean
clean:
	@rm -rf $(dir $(realpath $(firstword $(MAKEFILE_LIST))))/binaries
	@rm -rf $(dir $(realpath $(firstword $(MAKEFILE_LIST))))/build

go-lint:
	go get -u golang.org/x/lint/golint

gocyclo:
	go get -u github.com/fzipp/gocyclo

megacheck:
	go get -u honnef.co/go/tools/cmd/megacheck

misspell:
	go get -u github.com/client9/misspell/cmd/misspell

shfmt:
	go get -u mvdan.cc/sh/cmd/shfmt

ginkgo:
	go get -u github.com/onsi/ginkgo/ginkgo

go-get: go-lint gocyclo megacheck misspell shfmt ginkgo

package:
	@$(dir $(realpath $(firstword $(MAKEFILE_LIST))))/scripts/package.sh $(dir $(realpath $(firstword $(MAKEFILE_LIST))))build
