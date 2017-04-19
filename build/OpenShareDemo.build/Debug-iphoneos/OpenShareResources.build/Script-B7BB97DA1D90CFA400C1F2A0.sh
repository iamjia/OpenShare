#!/bin/sh
BUILD_BUNDLE_DIR=${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.bundle
TARGET_DIR=${SRCROOT}/build
TARGET_PATH=${SRCROOT}/build/${PRODUCT_NAME}.bundle

rm -rf "$TARGET_PATH"

if [ ! -d "$TARGET_DIR" ]; then
mkdir "$TARGET_DIR"
fi

cp -rf "$BUILD_BUNDLE_DIR" "$TARGET_PATH"
