clear
# Get Chromium source code tree
mkdir -p build/download_cache
./utils/downloads.py retrieve -c build/download_cache -i downloads.ini
./utils/downloads.py unpack -c build/download_cache -i downloads.ini -- build/src
# Prune Binaries
./utils/prune_binaries.py build/src pruning.list
# Apply patches
./utils/patches.py apply build/src patches
# Substitute domains
./utils/domain_substitution.py apply -r domain_regex.list -f domain_substitution.list -c build/domsubcache.tar.gz build/src
# Build GN. If you are using depot_tools to checkout Chromium or you already have a GN binary, you should skip this step
mkdir -p build/src/out/Default
cd build/src
./tools/gn/bootstrap/bootstrap.py --skip-generate-buildfiles -j4 -o out/Default/
# Compile RLBrowser
mkdir -p build/src/out/Default
# NOTE: flags.gn contains only a subset of what is needed to run the build.
cp flags.gn build/src/out/Default/args.gn
cd build/src
# If you have additional GN flags to add, make sure to add them now.
./out/Default/gn gen out/Default --fail-on-unused-args
CFLAGS="-O3 -march=native -flto -fvectorize -ffp-contract=fast" \
CXXFLAGS="$CFLAGS" \
LDFLAGS="-flto -fuse-ld=lld" \
ninja -j $(nproc) -C out/Default chrome chromedriver chrome_sandbox
