#!/bin/bash
set -e
cd "$(dirname "$0")"

APP_NAME="Automaker"
VERSION="v0.11"
NODE_VER=$(node -v)

ESC=$(printf '\033')
RESET="${ESC}[0m"
BOLD="${ESC}[1m"
DIM="${ESC}[2m"

C_PRI="${ESC}[38;5;51m"
C_SEC="${ESC}[38;5;39m"
C_ACC="${ESC}[38;5;33m"
C_GREEN="${ESC}[38;5;118m"
C_RED="${ESC}[38;5;196m"
C_GRAY="${ESC}[38;5;240m"
C_WHITE="${ESC}[38;5;255m"
C_MUTE="${ESC}[38;5;248m"

MODE="${1:-}"

hide_cursor() { printf "${ESC}[?25l"; }
show_cursor() { printf "${ESC}[?25h"; }

cleanup() {
    show_cursor
    printf "${RESET}\n"
}
trap cleanup EXIT INT TERM

get_term_size() {
    TERM_COLS=$(tput cols)
    TERM_LINES=$(tput lines)
}

draw_line() {
    local char="${1:-─}"
    local color="${2:-$C_GRAY}"
    local width="${3:-58}"
    printf "${color}"
    for ((i=0; i<width; i++)); do printf "%s" "$char"; done
    printf "${RESET}"
}

show_header() {
    clear
    get_term_size

    local top_pad=$(( TERM_LINES / 6 ))
    for ((i=0; i<top_pad; i++)); do echo ""; done

    local l1="  █▀▀█ █  █ ▀▀█▀▀ █▀▀█ █▀▄▀█ █▀▀█ █ █ █▀▀ █▀▀█  "
    local l2="  █▄▄█ █  █   █   █  █ █ ▀ █ █▄▄█ █▀▄ █▀▀ █▄▄▀  "
    local l3="  ▀  ▀  ▀▀▀   ▀   ▀▀▀▀ ▀   ▀ ▀  ▀ ▀ ▀ ▀▀▀ ▀ ▀▀  "

    local logo_width=52
    local pad_left=$(( (TERM_COLS - logo_width) / 2 ))
    local pad=$(printf "%${pad_left}s" "")

    echo -e "${pad}${C_PRI}${l1}${RESET}"
    echo -e "${pad}${C_SEC}${l2}${RESET}"
    echo -e "${pad}${C_ACC}${l3}${RESET}"

    echo ""
    local sub="Autonomous AI Development Studio  │  ${VERSION}"
    local sub_display_len=46
    local sub_pad=$(( (TERM_COLS - sub_display_len) / 2 ))
    printf "%${sub_pad}s" ""
    echo -e "${C_MUTE}Autonomous AI Development Studio${RESET}  ${C_GRAY}│${RESET}  ${C_GREEN}${VERSION}${RESET}"

    echo ""
    echo ""
}

show_menu() {
    local box_width=60
    local inner_width=58
    local pad_left=$(( (TERM_COLS - box_width) / 2 ))
    local pad=$(printf "%${pad_left}s" "")
    local border="${C_GRAY}│${RESET}"

    printf "%s${C_GRAY}╭" "$pad"
    draw_line "─" "$C_GRAY" "$inner_width"
    printf "╮${RESET}\n"

    printf "%s${border}  ${C_ACC}▸${RESET} ${C_PRI}[1]${RESET} 🌐  ${C_WHITE}Web Browser${RESET}       ${C_MUTE}localhost:3007${RESET}              ${border}\n" "$pad"
    printf "%s${border}    ${C_MUTE}[2]${RESET} 🖥   ${C_MUTE}Desktop App${RESET}       ${DIM}Electron${RESET}                    ${border}\n" "$pad"
    printf "%s${border}    ${C_MUTE}[3]${RESET} 🔧  ${C_MUTE}Desktop + Debug${RESET}   ${DIM}Electron + DevTools${RESET}         ${border}\n" "$pad"

    printf "%s${C_GRAY}├" "$pad"
    draw_line "─" "$C_GRAY" "$inner_width"
    printf "┤${RESET}\n"

    printf "%s${border}    ${C_RED}[Q]${RESET} ⏻   ${C_MUTE}Exit${RESET}                                          ${border}\n" "$pad"

    printf "%s${C_GRAY}╰" "$pad"
    draw_line "─" "$C_GRAY" "$inner_width"
    printf "╯${RESET}\n"

    echo ""
    local footer_text="Use keys [1-3] or [Q] to select"
    local f_pad=$(( (TERM_COLS - 31) / 2 ))
    printf "%${f_pad}s" ""
    echo -e "${DIM}${footer_text}${RESET}"
}

spinner() {
    local pid=$1
    local text="$2"
    local frames=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')
    local i=0

    tput civis

    while kill -0 "$pid" 2>/dev/null; do
        local len=${#text}
        local pad_left=$(( (TERM_COLS - len - 4) / 2 ))
        printf "\r%${pad_left}s${C_PRI}${frames[$i]}${RESET} ${C_WHITE}%s${RESET}" "" "$text"
        i=$(( (i + 1) % ${#frames[@]} ))
        sleep 0.08
    done

    local pad_left=$(( (TERM_COLS - ${#text} - 4) / 2 ))
    printf "\r%${pad_left}s${C_GREEN}✓${RESET} ${C_WHITE}%s${RESET}   \n" "" "$text"
    tput cnorm
}

launch_sequence() {
    local mode_name="$1"

    echo ""
    echo ""

    (sleep 0.5) & spinner $! "Initializing environment..."
    (sleep 0.5) & spinner $! "Starting $mode_name..."

    echo ""
    local msg="Automaker is ready!"
    local pad=$(( (TERM_COLS - 19) / 2 ))
    printf "%${pad}s${C_GREEN}${BOLD}%s${RESET}\n" "" "$msg"

    if [ "$MODE" == "web" ]; then
        local url="http://localhost:3007"
        local upad=$(( (TERM_COLS - 29) / 2 ))
        echo ""
        printf "%${upad}s${DIM}Opening ${C_SEC}%s${RESET}\n" "" "$url"
    fi
    echo ""
}

hide_cursor

if [ -z "$MODE" ]; then
    while true; do
        show_header
        show_menu

        if [ -n "$ZSH_VERSION" ]; then
            read -k 1 -s key
        else
            read -n 1 -s -r key
        fi

        case $key in
            1) MODE="web"; break ;;
            2) MODE="electron"; break ;;
            3) MODE="electron-debug"; break ;;
            q|Q)
                echo ""
                local msg="Goodbye!"
                local pad=$(( (TERM_COLS - 8) / 2 ))
                printf "%${pad}s${C_MUTE}%s${RESET}\n" "" "$msg"
                echo ""
                exit 0
                ;;
            *)
                ;;
        esac
    done
fi

case $MODE in
    web) MODE_NAME="Web Browser" ;;
    electron) MODE_NAME="Desktop App" ;;
    electron-debug) MODE_NAME="Desktop (Debug)" ;;
    *) echo "Invalid mode"; exit 1 ;;
esac

launch_sequence "$MODE_NAME"

case $MODE in
    web) npm run dev:web ;;
    electron) npm run dev:electron ;;
    electron-debug) npm run dev:electron:debug ;;
esac
