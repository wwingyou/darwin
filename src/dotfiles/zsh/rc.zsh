# attach to tmux after login to shell
if command -v tmux &>/dev/null; then
  if [ -z "$TMUX" ]; then
    tmux attach -t main || tmux new -s main
  fi
fi

# source custom zshrc logic
if [ -f "$HOME/.zshrc_custom" ]; then
  source "$HOME/.zshrc_custom"
fi
