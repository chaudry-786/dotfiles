# Define the cache directory
cache_dir=~/.pytest_completion_cache

# ensure_cache_directory exists when Zsh loads
ensure_cache_directory() {
    if [ ! -d "$cache_dir" ]; then
        mkdir -p "$cache_dir"
    fi
}
ensure_cache_directory

# Provides autocompletion for pytest test names.
_pytest_complete() {
    # Store the current context, state, and line arguments
    local curcontext="$curcontext" state line
    typeset -A opt_args

    local cache_key="$(pwd | tr '/' '_')"  # Replace '/' with '_'
    local cache_file="$cache_dir/test_names_$cache_key.cache"

    # Generate new cache if cache doesn't exist, is outdated, or is empty
    # Collect test names using pytest and store in cache file
    # Note: for the sake of performance we check timestamp of cache only against
    # current directory (not sub directories)
    if [ ! -f "$cache_file" ] ||
       [ "$(stat -c %Y "$cache_file")" -lt "$(ls -t1 test_*.py | head -n 1 | xargs stat -c %Y)" ] ||
       [ ! -s "$cache_file" ]; then
        pytest --collect-only -q 2>&1 | awk '/^test_/ { print $1 }' > "$cache_file"
    fi

    # Use cache for autocompletion
    compadd "$@" $(cat "$cache_file")
}
# Set up tab-completion for pytest
compdef _pytest_complete pytest
