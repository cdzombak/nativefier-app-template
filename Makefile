# Based on https://github.com/cdzombak/nativefier-app-template

SHELL:=/usr/bin/env bash

APPNAME="My Nativefier App"
VERSION=1.0.0
URL="https://example.com/"
define BUILD_FLAGS
-n ${APPNAME} \
--internal-urls ".*?" \
--min-width 550 \
--min-height 450 \
--width 670 \
--height 500 \
--app-version ${VERSION} \
--fast-quit \
--darwin-dark-mode-support \
-i icon.png
endef

# Optional Features:
# --bookmarks-menu bookmarks.json
# --inject userscript.js
# -i icon.icns  # usable once you've built once and extracted the .icns file from the resulting package; then future builders don't need ImageMagick

default: help
# via https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
.PHONY: help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: check-deps
check-deps:  ## Verify build-time dependencies are installed
	@command -v npm >/dev/null 2>&1 || echo "[!] Missing npm"
	@npm install

.PHONY: update-deps
update-deps: check-deps  ## Update the application's dependencies (eg. nativefier)
	npm update

.PHONY: clean
clean:  ## Clean build output directory
	rm -rf ./out

.PHONY: build
build: clean check-deps update-deps  ## Build app for the current platform
	mkdir -p ./out
	npm exec nativefier -- ${URL} ${BUILD_FLAGS} ./out

.PHONY: install-mac
install-mac: build  ## Build & install to /Applications (on macOS, Intel or Apple Silicon)
	cp -R ./out/${APPNAME}-darwin-x64/${APPNAME}.app /Applications || cp -R ./out/${APPNAME}-darwin-arm64/${APPNAME}.app /Applications
	#rm -rf ./out

.PHONY: build-all
build-all: clean check-deps  ## Build app for supported platforms
	mkdir -p ./out
	npm exec nativefier -- ${URL} ${BUILD_FLAGS} -p mac -a x64 ./out
	pushd ./out/${APPNAME}-darwin-x64 &&  zip -r ../${APPNAME}-${VERSION}-macos-x64.zip ./${APPNAME}.app && popd
	npm exec nativefier -- ${URL} ${BUILD_FLAGS} -p mac -a arm64 ./out
	pushd ./out/${APPNAME}-darwin-arm64 &&  zip -r ../${APPNAME}-${VERSION}-macos-arm.zip ./${APPNAME}.app && popd

# TODO: Windows & Linux support
# 	npm exec nativefier -- ${URL} ${BUILD_FLAGS} -p windows -a x64 ./out/windows-x64
# 	npm exec nativefier -- ${URL} ${BUILD_FLAGS} -p windows -a arm64 ./out/windows-arm
