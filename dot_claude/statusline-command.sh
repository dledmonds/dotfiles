#!/bin/bash
# Claude Code status line
# Shows: model, context window % used, tokens used, and % used of the
# current rate-limit period (5-hour session window).

input=$(cat)

model=$(echo "$input" | jq -r '.model.display_name // "unknown"')
context_used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
input_tokens=$(echo "$input" | jq -r '.context_window.total_input_tokens // 0')
output_tokens=$(echo "$input" | jq -r '.context_window.total_output_tokens // 0')
total_tokens=$((input_tokens + output_tokens))
period_pct=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')

# Add thousands separators to the token count (portable, no locale dependency)
tokens_fmt=$(printf "%d" "$total_tokens" | sed -E ':a;s/([0-9])([0-9]{3})(,|$)/\1,\2\3/;ta')

# Dim colors, suited for a terminal footer
DIM_CYAN='\033[2;36m'
DIM_YELLOW='\033[2;33m'
DIM_GREEN='\033[2;32m'
DIM_MAGENTA='\033[2;35m'
RESET='\033[0m'

parts=()
parts+=("$(printf "${DIM_CYAN}%s${RESET}" "$model")")

if [ -n "$context_used" ]; then
  parts+=("$(printf "${DIM_YELLOW}Ctx %.0f%%${RESET}" "$context_used")")
fi

parts+=("$(printf "${DIM_GREEN}Tokens %s${RESET}" "$tokens_fmt")")

if [ -n "$period_pct" ]; then
  parts+=("$(printf "${DIM_MAGENTA}Usage %.0f%%${RESET}" "$period_pct")")
fi

output=""
sep=" | "
first=true
for p in "${parts[@]}"; do
  if [ "$first" = true ]; then
    output="$p"
    first=false
  else
    output="$output$sep$p"
  fi
done

printf "%s\n" "$output"
