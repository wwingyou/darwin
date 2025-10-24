# attach to tmux after login to shell
if command -v tmux &>/dev/null; then
  if [ -z "$TMUX" ]; then
    tmux attach -t main || tmux new -s main
  fi
fi
