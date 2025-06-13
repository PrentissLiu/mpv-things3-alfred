#!/bin/bash

SOCAT_PATH="/usr/local/bin/socat"
JQ_PATH="/usr/local/bin/jq"

MPV_SOCKET="/tmp/mpvsocket"

if [ ! -S "$MPV_SOCKET" ]; then
    echo "错误: 未找到mpv通信端口。"
    exit 1
fi

get_property() {
    echo '{ "command": ["get_property", "'"$1"'"] }' | "$SOCAT_PATH" - "$MPV_SOCKET" | "$JQ_PATH" -r '.data'
}

filepath=$(get_property 'path')
playtime=$(get_property 'time-pos')
playspeed=$(get_property 'speed')


total_seconds=${playtime%.*}

if (( total_seconds >= 3600 )); then
    # 如果大于等于1小时，换算成 "X小时X分"
    hours=$((total_seconds / 3600))
    minutes=$(((total_seconds % 3600) / 60))
    time_string="${hours}小时${minutes}分"
else
    # 如果不足1小时，直接换算成 "X分"
    minutes=$((total_seconds / 60))
    time_string="${minutes}分"
fi


if [ -z "$filepath" ] || [ -z "$playtime" ] || [ -z "$playspeed" ]; then
    echo "错误: 无法获取MPV播放信息。"
    exit 1
fi

# --- 关键修正：统一使用无空格的 "mpvrecover" 作为格式前缀 ---
output_string="mpvrecover file:${filepath} time:${playtime} speed:${playspeed}"

# 将字符串复制到系统剪贴板
echo -n "$output_string" | pbcopy


# --- 集成Things 3快捷输入窗口 ---
filename=$(basename "$filepath")
todo_title="继续播放：$filename  |已播 ${time_string} "
todo_notes="
\`\`\`
${output_string}
\`\`\`
"
encoded_title=$(echo -n "$todo_title" | "$JQ_PATH" -sRr @uri)
encoded_notes=$(echo -n "$todo_notes" | "$JQ_PATH" -sRr @uri)
things_url="things:///add?show-quick-entry=true&title=${encoded_title}&notes=${encoded_notes}&when=today"
open "$things_url"

echo "MPV状态已复制, Things 3快捷输入已弹出"