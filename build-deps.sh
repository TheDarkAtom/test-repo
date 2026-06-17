Toolchain="$1"

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DIR"

source ./common.sh "$Toolchain"

export PATH="$DIR/toolchain/mingw/bin:$PATH"

# zlib
echo "Configuring zlib..."
cmake -S "$DIR/deps/zlib" -B "$DIR/deps/build/zlib" "${commonArgs[@]}" \
    -DZLIB_BUILD_TESTING=OFF \
    -DZLIB_BUILD_SHARED=OFF \
    -DCMAKE_INTERPROCEDURAL_OPTIMIZATION=ON
[[ $? -ne 0 ]] && { echo "Configure failed, aborting..."; exit 1; }

echo "Building zlib..."
cmake --build "$DIR/deps/build/zlib"
[[ $? -ne 0 ]] && { echo "Build failed, aborting..."; exit 1; }

echo "Installing zlib..."
cmake --install "$DIR/deps/build/zlib"
[[ $? -ne 0 ]] && { echo "Install failed, aborting..."; exit 1; }


# wxWidgets
echo "Configuring wxWidgets..."
cmake -S "$DIR/deps/wxWidgets" -B "$DIR/deps/build/wx" "${commonArgs[@]}" "${commonArgsCxx[@]}" \
    -DCMAKE_PREFIX_PATH="$installDir" \
    -DwxBUILD_INSTALL=ON \
    -DwxBUILD_SHARED=OFF \
    -DwxBUILD_USE_STATIC_RUNTIME=ON \
    -DwxBUILD_PRECOMP=OFF \
    -DwxUSE_ZLIB=sys \
    -DZLIB_LIBRARY="$installDir/lib/libzs.a" \
    -DZLIB_INCLUDE_DIR="$installDir/include"
[[ $? -ne 0 ]] && { echo "Configure failed, aborting..."; exit 1; }

echo "Building wxWidgets..."
cmake --build "$DIR/deps/build/wx"
[[ $? -ne 0 ]] && { echo "Build failed, aborting..."; exit 1; }

echo "Installing wxWidgets..."
cmake --install "$DIR/deps/build/wx"
[[ $? -ne 0 ]] && { echo "Install failed, aborting..."; exit 1; }

echo "Done."