# Check for the directory to save commands
CMDBOX_DIR="$HOME/.cmdbox"
if [[ ! -d $CMDBOX_DIR ]]; then
    mkdir -p "$CMDBOX_DIR"
fi

# Function to ensure the CMDBOX_DIR exists
ensure_cmdbox_dir() {
    if [[ ! -d $CMDBOX_DIR ]]; then
        mkdir -p "$CMDBOX_DIR"
    fi
}

# Save a command with a keyword
cmdbox_save_command() {
    ensure_cmdbox_dir  # Ensure the directory exists

    if [[ $# -lt 2 ]]; then
        echo "Usage: cmdbox save keyword \"command\""
        return
    fi

    local keyword="$1"
    shift
    local command="$*"

    if [[ -z "$keyword" || -z "$command" ]]; then
        echo "Keyword and command cannot be empty."
        return
    fi

    echo "$command" > "$CMDBOX_DIR/$keyword"
    echo "Cmdbox Saved: $keyword -> $command"
}

# Use a saved command
cmdbox_use_command() {
    ensure_cmdbox_dir  # Ensure the directory exists
    echo "Available commands:"
    ls "$CMDBOX_DIR"

    read -p "Enter the keyword of the command to use: " keyword

    if [[ -f "$CMDBOX_DIR/$keyword" ]]; then
        local command=$(cat "$CMDBOX_DIR/$keyword")
        echo "Cmdbox command for '$keyword': $command"

        # Confirm before executing
        read "response?Run this command? [y/N]: "
        if [[ "$response" =~ ^[Yy]$ ]]; then
            eval "$command"
        else
            echo "Command aborted."
        fi
    else
        echo "No command found with the keyword '$keyword'."
    fi
}

# List saved cmdbox commands
cmdbox_list_commands() {
    ensure_cmdbox_dir  # Ensure the directory exists
    echo "Saved cmdbox commands:"
    for cmdbox_file in "$CMDBOX_DIR"/*; do
        local keyword=$(basename "$cmdbox_file")
        echo "- $keyword: $(cat "$cmdbox_file")"
    done
}

# Help command
cmdbox_help() {
    echo "Cmdbox Plugin - Command shortcuts:"
    echo " cmdbox save: Save a command with a keyword"
    echo " cmdbox use: Use a command already saved."
    echo " cmdbox list: List all commands inside your cmdbox folder"
    echo " cmdbox help: Show this help message"
}

# Main function to handle subcommands
cmdbox() {
    case $1 in
        help)
            cmdbox_help
            ;;
        save)
            cmdbox_save_command
            ;;
        use)
            cmdbox_use_command
            ;;
        list)
            cmdbox_list_commands
            ;;
        *)
            echo "Invalid command. Use 'cmdbox help' for usage."
            ;;
    esac
}

# Ensure the CMDBOX_DIR exists at the start
ensure_cmdbox_dir
