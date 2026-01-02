function u
    # Previous commands...
    cargo install-update
    if command -v rustup &> /dev/null; then
        rustup update
    fi
    # Other commands
end
