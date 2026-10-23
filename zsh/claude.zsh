# Name new interactive Claude sessions after the current directory (same as /rename),
# so they show up labeled in the prompt, the /resume picker and the terminal title.
# Resumed, continued, headless and already-named sessions are passed through untouched.
claude() {
  local arg
  for arg in "$@"; do
    case "$arg" in
      -n|--name|--name=*|-r|--resume|--resume=*|-c|--continue|-p|--print) command claude "$@"; return ;;
    esac
  done
  command claude --name "${PWD:t}" "$@"
}
