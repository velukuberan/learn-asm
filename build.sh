#!/bin/bash

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Icons
CHECK="✅"
CROSS="❌"
ROCKET="🚀"
HAMMER="🔨"
SPARKLES="✨"
GEAR="⚙️"
FILE_ICON="📄"
PLAY="▶️"

# Functions for additional commands
format() {
    echo -e "${BLUE}${SPARKLES} Formatting assembly code...${NC}"
    # Format any C helper files if they exist
    find src/ -name "*.c" -o -name "*.h" 2>/dev/null | xargs -r clang-format -i
    # Note: Assembly files don't have standard formatters, but we could add custom formatting here
    echo -e "${GREEN}${CHECK} Formatting complete${NC}"
}

display() {
    # Clear screen at the start for clean interface
    clear

    echo -e "${BLUE}${SPARKLES} Available Assembly Executables${NC}"
    echo

    # Check if debug and release directories exist
    debug_count=0
    release_count=0

    if [ -d "debug" ]; then
        debug_count=$(find debug/ -type f -executable 2>/dev/null | wc -l)
    fi

    if [ -d "release" ]; then
        release_count=$(find release/ -type f -executable 2>/dev/null | wc -l)
    fi

    total_count=$((debug_count + release_count))

    if [ $total_count -eq 0 ]; then
        echo -e "${RED}${CROSS} No executable files found${NC}"
        echo -e "${YELLOW}Run 'make all-debug' or 'make all-release' first to build executables${NC}"
        return 1
    fi

    # Get all executables
    all_executables=()
    while IFS= read -r -d '' file; do
        all_executables+=("$file")
    done < <(find debug/ release/ -type f -executable -print0 2>/dev/null)

    # Show summary
    echo -e "${GREEN}Found $total_count executable(s):${NC}"
    echo -e "  ${CYAN}Debug builds: $debug_count${NC}"
    echo -e "  ${CYAN}Release builds: $release_count${NC}"
    echo

    # Filter options
    echo -e "${YELLOW}Filter options:${NC}"
    echo -e "  ${BLUE}[Enter search term]${NC} Search for specific files"
    echo -e "  ${BLUE}[nasm]${NC} Show only NASM executables"
    echo -e "  ${BLUE}[gcc]${NC} Show only GCC executables"
    echo -e "  ${BLUE}[debug]${NC} Show only debug builds"
    echo -e "  ${BLUE}[release]${NC} Show only release builds"
    echo -e "  ${BLUE}[*]${NC} Show all files"
    echo -e "  ${BLUE}[q]${NC} Quit"
    echo
    read -p "Filter/Search: " search_term

    # Handle quit
    if [[ "$search_term" == "q" || "$search_term" == "Q" ]]; then
        clear
        echo -e "${BLUE}Cancelled${NC}"
        return
    fi

    # Filter executables based on search
    filtered_executables=()
    case "$search_term" in
    "nasm")
        for exe in "${all_executables[@]}"; do
            if [[ "$exe" == *"/nasm/"* ]]; then
                filtered_executables+=("$exe")
            fi
        done
        ;;
    "gcc")
        for exe in "${all_executables[@]}"; do
            if [[ "$exe" == *"/gcc/"* ]]; then
                filtered_executables+=("$exe")
            fi
        done
        ;;
    "debug")
        for exe in "${all_executables[@]}"; do
            if [[ "$exe" == debug/* ]]; then
                filtered_executables+=("$exe")
            fi
        done
        ;;
    "release")
        for exe in "${all_executables[@]}"; do
            if [[ "$exe" == release/* ]]; then
                filtered_executables+=("$exe")
            fi
        done
        ;;
    "*" | "")
        filtered_executables=("${all_executables[@]}")
        ;;
    *)
        # Search for matching files (case-insensitive)
        for exe in "${all_executables[@]}"; do
            filename=$(basename "$exe")
            if [[ "${filename,,}" == *"${search_term,,}"* ]]; then
                filtered_executables+=("$exe")
            fi
        done
        ;;
    esac

    # Check if any matches found
    if [ ${#filtered_executables[@]} -eq 0 ]; then
        clear
        echo -e "${RED}${CROSS} No executables found matching '$search_term'${NC}"
        echo -e "${YELLOW}Available files:${NC}"
        for exe in "${all_executables[@]}"; do
            # Extract type and mode from path
            type_mode=$(echo "$exe" | sed 's|^[^/]*/\([^/]*\)/\([^/]*\)/.*|\1 (\2)|')
            echo -e "  ${GREEN}$(basename "$exe")${NC} ${CYAN}[$type_mode]${NC}"
        done
        echo
        echo -e "${BLUE}Press Enter to search again...${NC}"
        read
        display # Restart search
        return
    fi

    # Clear screen before showing results
    clear

    # Display filtered results header
    echo -e "${BLUE}${SPARKLES} Assembly Executable Search Results${NC}"
    echo
    if [[ "$search_term" == "*" || -z "$search_term" ]]; then
        echo -e "${GREEN}${CHECK} Showing all ${#filtered_executables[@]} executable(s):${NC}"
    else
        echo -e "${GREEN}${CHECK} Found ${#filtered_executables[@]} executable(s) matching '$search_term':${NC}"
    fi
    echo

    # Display numbered list with enhanced info
    for i in "${!filtered_executables[@]}"; do
        filename=$(basename "${filtered_executables[$i]}")
        filepath="${filtered_executables[$i]}"

        # Extract build type and compiler from path
        if [[ "$filepath" == debug/nasm/* ]]; then
            type_info="${PURPLE}[NASM Debug]${NC}"
        elif [[ "$filepath" == debug/gcc/* ]]; then
            type_info="${PURPLE}[GCC Debug]${NC}"
        elif [[ "$filepath" == release/nasm/* ]]; then
            type_info="${CYAN}[NASM Release]${NC}"
        elif [[ "$filepath" == release/gcc/* ]]; then
            type_info="${CYAN}[GCC Release]${NC}"
        else
            type_info="${YELLOW}[Unknown]${NC}"
        fi

        echo -e "${GREEN}$((i + 1)). $filename${NC} $type_info ${BLUE}(./$filepath)${NC}"
    done

    echo
    echo -e "${BLUE}Options:${NC}"
    echo -e "  ${YELLOW}[1-${#filtered_executables[@]}]${NC} Run selected executable"
    echo -e "  ${YELLOW}[a]${NC} Run all filtered executables"
    echo -e "  ${YELLOW}[s]${NC} Search again"
    echo -e "  ${YELLOW}[Enter]${NC} Just list (no execution)"
    echo
    read -p "Your choice: " choice

    case "$choice" in
    [1-9] | [1-9][0-9])
        if [ "$choice" -ge 1 ] && [ "$choice" -le ${#filtered_executables[@]} ]; then
            selected_file="${filtered_executables[$((choice - 1))]}"

            # Clear screen before execution
            clear
            echo -e "${ROCKET} Running: $(basename "$selected_file")${NC}"

            # Show build info
            if [[ "$selected_file" == debug/nasm/* ]]; then
                echo -e "${PURPLE}Type: NASM Assembly (Debug Build)${NC}"
            elif [[ "$selected_file" == debug/gcc/* ]]; then
                echo -e "${PURPLE}Type: GCC Assembly (Debug Build)${NC}"
            elif [[ "$selected_file" == release/nasm/* ]]; then
                echo -e "${CYAN}Type: NASM Assembly (Release Build)${NC}"
            elif [[ "$selected_file" == release/gcc/* ]]; then
                echo -e "${CYAN}Type: GCC Assembly (Release Build)${NC}"
            fi

            echo "========================================"

            # Run with error handling
            if "./$selected_file"; then
                echo "========================================"
                echo -e "${GREEN}${CHECK} Execution completed successfully${NC}"
            else
                echo "========================================"
                echo -e "${RED}${CROSS} Execution failed (exit code: $?)${NC}"
            fi

            echo
            echo -e "${BLUE}Press Enter to continue...${NC}"
            read

            # Ask if user wants to run another or exit
            clear
            echo -e "${YELLOW}What would you like to do next?${NC}"
            echo -e "  ${GREEN}[1]${NC} Search/run another executable"
            echo -e "  ${GREEN}[2]${NC} Exit to shell"
            echo
            read -p "Your choice (1/2): " next_choice

            case "$next_choice" in
            1)
                display # Restart display function
                ;;
            *)
                clear
                echo -e "${GREEN}${CHECK} Done!${NC}"
                ;;
            esac
        else
            echo -e "${RED}${CROSS} Invalid selection (1-${#filtered_executables[@]})${NC}"
            echo -e "${BLUE}Press Enter to try again...${NC}"
            read
            display # Restart on invalid selection
        fi
        ;;
    [aA])
        # Clear screen before running all
        clear
        echo -e "${ROCKET} Running all filtered executables...${NC}"
        echo

        for exe in "${filtered_executables[@]}"; do
            echo -e "${BLUE}🔹 Running: $(basename "$exe")${NC}"

            # Show type info
            if [[ "$exe" == debug/nasm/* ]]; then
                echo -e "${PURPLE}   Type: NASM Assembly (Debug)${NC}"
            elif [[ "$exe" == debug/gcc/* ]]; then
                echo -e "${PURPLE}   Type: GCC Assembly (Debug)${NC}"
            elif [[ "$exe" == release/nasm/* ]]; then
                echo -e "${CYAN}   Type: NASM Assembly (Release)${NC}"
            elif [[ "$exe" == release/gcc/* ]]; then
                echo -e "${CYAN}   Type: GCC Assembly (Release)${NC}"
            fi

            echo "----------------------------------------"
            if "./$exe"; then
                echo -e "${GREEN}${CHECK} Success${NC}"
            else
                echo -e "${RED}${CROSS} Failed (exit code: $?)${NC}"
            fi
            echo "----------------------------------------"
            echo
        done

        echo -e "${GREEN}${CHECK} All executions completed${NC}"
        echo
        echo -e "${BLUE}Press Enter to continue...${NC}"
        read

        # Ask what to do next
        clear
        echo -e "${YELLOW}What would you like to do next?${NC}"
        echo -e "  ${GREEN}[1]${NC} Search/run more executables"
        echo -e "  ${GREEN}[2]${NC} Exit to shell"
        echo
        read -p "Your choice (1/2): " next_choice

        case "$next_choice" in
        1)
            display
            ;;
        *)
            clear
            echo -e "${GREEN}${CHECK} Done!${NC}"
            ;;
        esac
        ;;
    [sS])
        # Clear and restart search
        display
        ;;
    "")
        clear
        echo -e "${BLUE}Listed filtered executables only${NC}"
        echo -e "${BLUE}Press Enter to search again or Ctrl+C to exit...${NC}"
        read
        display
        ;;
    *)
        echo -e "${RED}${CROSS} Invalid option${NC}"
        echo -e "${BLUE}Press Enter to try again...${NC}"
        read
        display # Restart on invalid option
        ;;
    esac
}

clean() {
    echo -e "${YELLOW}${HAMMER} Cleaning build directories...${NC}"
    echo -e "${BLUE}Removing debug/ and release/ directories...${NC}"
    rm -rf debug/ release/
    echo -e "${GREEN}${CHECK} Clean complete${NC}"
}

build_all() {
    echo -e "${BLUE}${GEAR} Building all assembly files...${NC}"
    echo

    if make all-debug; then
        echo -e "${GREEN}${CHECK} Debug build successful${NC}"
    else
        echo -e "${RED}${CROSS} Debug build failed${NC}"
        return 1
    fi

    echo

    if make all-release; then
        echo -e "${GREEN}${CHECK} Release build successful${NC}"
    else
        echo -e "${RED}${CROSS} Release build failed${NC}"
        return 1
    fi

    echo
    echo -e "${GREEN}${CHECK} All builds completed successfully!${NC}"
    echo -e "${BLUE}Use './build.sh display' to run executables${NC}"
}

show_help() {
    echo -e "${BLUE}${SPARKLES} Assembly Project Build Script${NC}"
    echo -e "${GREEN}Usage: ./build.sh [command]${NC}"
    echo
    echo -e "${YELLOW}Commands:${NC}"
    echo -e "  ${CYAN}build${NC}     Build all assembly files (debug + release)"
    echo -e "  ${CYAN}display${NC}   Search and run compiled executables"
    echo -e "  ${CYAN}clean${NC}     Clean all build directories"
    echo -e "  ${CYAN}format${NC}    Format source code"
    echo -e "  ${CYAN}help${NC}      Show this help message"
    echo
    echo -e "${YELLOW}Examples:${NC}"
    echo -e "  ${GREEN}./build.sh build${NC}     # Build everything"
    echo -e "  ${GREEN}./build.sh display${NC}   # Interactive executable runner"
    echo -e "  ${GREEN}./build.sh clean${NC}     # Clean build files"
    echo
    echo -e "${YELLOW}Makefile commands (alternative):${NC}"
    echo -e "  ${GREEN}make nasm-debug${NC}      # Build NASM files (debug)"
    echo -e "  ${GREEN}make gcc-release${NC}     # Build GCC files (release)"
    echo -e "  ${GREEN}make all-debug${NC}       # Build all files (debug)"
    echo -e "  ${GREEN}make help${NC}            # Show Makefile help"
}

# Handle arguments
case "$1" in
"format")
    format
    exit 0
    ;;
"display")
    display
    exit 0
    ;;
"clean")
    clean
    exit 0
    ;;
"build")
    build_all
    exit 0
    ;;
"help" | "-h" | "--help")
    show_help
    exit 0
    ;;
"")
    # Default: show help
    show_help
    ;;
*)
    echo -e "${RED}${CROSS} Unknown command: $1${NC}"
    echo -e "${YELLOW}Use './build.sh help' for available commands${NC}"
    exit 1
    ;;
esac
