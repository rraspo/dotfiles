ZSHRC_USER_HOST="%F{cyan}%n@%m:%f"
ZSHRC_CURRENT_DIR="%F{cyan}%~%f"
ZSHRC_CONDITIONAL="%(?.%F{green}.%F{red})➜ %f"
PROMPT="${ZSHRC_USER_HOST}${ZSHRC_CURRENT_DIR} ${ZSHRC_CONDITIONAL}"
PROMPT+=' $(git_prompt_info)'
