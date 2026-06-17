Branch="$1"
Toolchain="$2"

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DIR"

source "$DIR/common.sh" "$Toolchain"

echo "Cloning repository..."
git clone https://codeberg.org/DarkAtom/titan-editor.git
[[ $? -ne 0 ]] && { echo "Clone failed, aborting..."; exit 1; }

echo "Switching to branch $Branch..."
cd titan-editor
git checkout "$Branch"
[[ $? -ne 0 ]] && { echo "Checkout failed, aborting..."; exit 1; }
cd "$DIR"

echo "Done."

export PATH="$DIR/toolchain/mingw/bin:$PATH"

echo "Configuring..."
cmake -S "titan-editor" -B "$DIR/build" "${commonArgs[@]}" "${commonArgsCxx[@]}" \
    -DZLIB_LIBRARY="$installDir/lib/libzs.a" \
    -DZLIB_INCLUDE_DIR="$installDir/include" \
    -DwxWidgets_CONFIGURATION=mswu
[[ $? -ne 0 ]] && { echo "Configure failed, aborting..."; exit 1; }

echo "Building..."
cmake --build "$DIR/build"
[[ $? -ne 0 ]] && { echo "Build failed, aborting..."; exit 1; }

echo "Stripping debug symbols..."
llvm-objcopy --only-keep-debug "$DIR/build/TitanEditor.exe" "$DIR/build/TitanEditor.debug"
llvm-objcopy --strip-debug "--add-gnu-debuglink=$DIR/build/TitanEditor.debug" "$DIR/build/TitanEditor.exe"

echo "Done."