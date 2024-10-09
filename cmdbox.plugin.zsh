# Check for the directory to save commands
CMDBOX_DIR="$HOME/.cmdbox"
if [[ ! -d $CMDBOX_DIR ]]; then
    mkdir -p "$CMDBOX_DIR"
fi

# Install ncurses
function install_ncurses() {
    if command -v ncurses &> /dev/null; then
        return 0
    fi

    echo "ncurses is not installed. Attempting to install..."

    if command -v apt-get &> /dev/null; then
        sudo apt-get update && sudo apt-get install -y libncurses5-dev libncursesw5-dev
    elif command -v brew &> /dev/null; then
        brew install ncurses
    else
        echo "Unsupported package manager. Please install ncurses manually."
        return 1
    fi

    return 0
}

# Load ncurses
function load_ncurses() {
    if ! install_ncurses; then
        echo "Failed to install ncurses. Exiting."
        return 1
    fi
}

# Show a simple menu using ncurses
function show_menu() {
    local options=("Save Command" "Use Command" "List Commands" "Help" "Exit")
    local selected=1  # Start with the first option highlighted

    tput clear
    echo "==== Cmdbox Command Menu ===="
    echo

    while true; do
        for (( i=1; i<=${#options[@]}; i++ )); do
            if (( i == selected )); then
                echo -e "\e[1;32m> ${options[i-1]}\e[0m"  # Highlight the selected option
            else
                echo "  ${options[i-1]}"
            fi
        done

        read -rsn1 input
        case $input in
            $'\e[B')  # Down arrow
                ((selected=(selected % ${#options[@]}) + 1))
                ;;
            $'\e[A')  # Up arrow
                ((selected=(selected - 2 + ${#options[@]}) % ${#options[@]} + 1))
                ;;
            "")
                case ${options[selected-1]} in
                    "Save Command")
                        cmdbox_save_command_prompt
                        ;;
                    "Use Command")
                        cmdbox_use_command_prompt
                        ;;
                    "List Commands")
                        cmdbox_list_commands_prompt
                        ;;
                    "Help")
                        cmdbox_help_command_prompt  # Fixed typo here
                        ;;
                    "Exit")
                        tput clear
                        break
                        ;;
                esac
                ;;
        esac
        tput clear
    done
}

# Save a command with a keyword
cmdbox_save_command_prompt() {
    read -p "Enter keyword: " keyword
    read -p "Enter command: " command
    echo "$command" > "$CMDBOX_DIR/$keyword"
    echo "Cmdbox Saved: $keyword -> $command"
}

# Use a saved command
cmdbox_use_command_prompt() {
    echo "Select a command to use"
    local cmdbox_file
    cmdbox_file=$(ls "$CMDBOX_DIR" | fzf --header="Select a command to run")

    if [[ -z "$cmdbox_file" ]]; then
        echo "No command selected"
        return
    fi
    
    local command=$(cat "$CMDBOX_DIR/$cmdbox_file")
    echo "Cmdbox command for '$cmdbox_file': $command"

    # Confirm before executing
    read "response?Run this command? [y/N]: "
    if [[ "$response" =~ ^[Yy]$ ]]; then  # Fixed syntax here
        eval "$command"
    else
        echo "Command aborted."
    fi
}

# List saved cmdbox commands
cmdbox_list_commands_prompt() {
    echo "Saved cmdbox commands:"
    for cmdbox_file in "$CMDBOX_DIR"/*; do
        local keyword=$(basename "$cmdbox_file")
        echo "- $keyword: $(cat "$cmdbox_file")"
    done
}

# Help command
cmdbox_help_command_prompt() {
    echo "Cmdbox Plugin - Command shortcuts:"
    echo " Save command: Save a command with a keyword"
    echo " Use command: Use a command already saved."
    echo " List commands: List all commands inside your cmdbox folder"
    echo " Help: Show this help message"
}

load_ncurses
show_menu
