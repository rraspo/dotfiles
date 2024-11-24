# Prefered prompt with git plugin

ZSHRC_USER_HOST="%F{cyan}%n@%m:%f" # user@host
ZSHRC_CURRENT_DIR="%F{cyan}%~%f" # current dir
ZSHRC_CONDITIONAL="%(?.%F{green}.%F{red})➜ %f" # colored arrow
PROMPT="${ZSHRC_USER_HOST}${ZSHRC_CURRENT_DIR} ${ZSHRC_CONDITIONAL}"
PROMPT+=' $(git_prompt_info)'
