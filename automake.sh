clear
# Get Chromium source code tree
mkdir -p build/download_cache
./utils/downloads.py retrieve -c build/download_cache -i downloads.ini
./utils/downloads.py unpack -c build/download_cache -i downloads.ini -- build/src
# Prune Binaries
./utils/prune_binaries.py build/src pruning.list