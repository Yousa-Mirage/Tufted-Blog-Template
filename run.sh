#!/usr/bin/env bash
# One-command local development server for Tufted Blog Template.
#
# The script checks required tools, prints installation hints when something is
# missing, builds the site once, starts the preview server, then rebuilds when
# source files change.

set -uo pipefail
set -m

cd "$(dirname "$0")"

PORT=8000
USE_PYTHON=0
RUNNER=(uv run build.py)
WATCH=(content tufted-lib assets config.typ)

usage() {
	cat <<EOF
Usage: $(basename "$0") [-p PORT] [--python]

  -p, --port PORT  Preview server port (default: 8000)
      --python     Run 'python build.py' instead of 'uv run build.py'
  -h, --help       Show this help message

Press Ctrl+C to stop the preview server and file watcher.
EOF
}

print_install_hints() {
	cat <<'EOF'

Install the missing tools, then run ./run.sh again.

macOS with Homebrew:
  brew install uv typst fswatch

uv official installer:
  curl -LsSf https://astral.sh/uv/install.sh | sh

Typst downloads and other installers:
  https://typst.app/open-source/#download

Linux watcher dependency (optional, otherwise polling is used):
  sudo apt install inotify-tools
EOF
}

while [[ $# -gt 0 ]]; do
	case "$1" in
		-p | --port)
			PORT="${2:?-p/--port requires a port}"
			shift 2
			;;
		--python)
			USE_PYTHON=1
			RUNNER=(python build.py)
			shift
			;;
		-h | --help)
			usage
			exit 0
			;;
		*)
			echo "Unknown argument: $1" >&2
			usage >&2
			exit 1
			;;
	esac
done

check_required_dependencies() {
	local missing=()

	if [[ "$USE_PYTHON" -eq 1 ]]; then
		if ! command -v python >/dev/null 2>&1; then
			missing+=("python")
		fi
	else
		if ! command -v uv >/dev/null 2>&1; then
			missing+=("uv")
		fi
	fi

	if ! command -v typst >/dev/null 2>&1; then
		missing+=("typst")
	fi

	if [[ "${#missing[@]}" -gt 0 ]]; then
		echo "Missing required tool(s): ${missing[*]}" >&2
		print_install_hints >&2
		exit 1
	fi
}

describe_watcher() {
	if command -v fswatch >/dev/null 2>&1; then
		echo "Using watcher: fswatch"
	elif command -v inotifywait >/dev/null 2>&1; then
		echo "Using watcher: inotifywait"
	else
		echo "Using watcher: polling every 1s"
		echo "Tip: install fswatch on macOS or inotify-tools on Linux for instant rebuilds."
	fi
}

check_required_dependencies
describe_watcher

echo "Initial build"
if ! "${RUNNER[@]}" build; then
	echo "Initial build failed. Fix the Typst error; the watcher will rebuild on changes." >&2
fi

echo "Starting preview server: http://localhost:${PORT}"
"${RUNNER[@]}" preview -p "$PORT" &
PREVIEW_PID=$!

watcher() {
	if command -v fswatch >/dev/null 2>&1; then
		fswatch -o "${WATCH[@]}" | while read -r _; do
			echo "Change detected. Rebuilding..."
			"${RUNNER[@]}" build || true
		done
	elif command -v inotifywait >/dev/null 2>&1; then
		while inotifywait -qqr -e modify,create,delete,move "${WATCH[@]}"; do
			echo "Change detected. Rebuilding..."
			"${RUNNER[@]}" build || true
		done
	else
		local stamp
		stamp=$(mktemp)
		touch "$stamp"
		while sleep 1; do
			if find "${WATCH[@]}" -type f -newer "$stamp" -print -quit 2>/dev/null | grep -q .; then
				touch "$stamp"
				echo "Change detected. Rebuilding..."
				"${RUNNER[@]}" build || true
			fi
		done
	fi
}

watcher &
WATCHER_PID=$!

cleanup() {
	trap - INT TERM EXIT
	echo
	echo "Stopping..."
	kill -TERM -- "-$PREVIEW_PID" "-$WATCHER_PID" 2>/dev/null || true
	wait 2>/dev/null || true
	exit 0
}

trap cleanup INT TERM EXIT
wait "$PREVIEW_PID"
