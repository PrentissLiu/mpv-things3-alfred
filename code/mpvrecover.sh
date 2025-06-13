#!/bin/bash

# 从剪贴板读取数据
data=$(pbpaste)

# --- 关键修正：检查正确的前缀 "mpvrecover " ---
if [[ ! "$data" == "mpvrecover "* ]]; then
    echo "剪贴板内容格式不正确！"
    exit 1
fi

# --- 解析字符串 ---
temp=${data#*file:}
filepath=${temp%% time:*}
temp=${data#*time:}
playtime=${temp%% speed:*}
playspeed=${data#*speed:}

# --- 执行恢复命令 ---
MPV_PATH="/usr/local/bin/mpv"

# "$filepath" 的双引号会处理好文件名中的空格问题
nohup "$MPV_PATH" --start="$playtime" --speed="$playspeed" "$filepath" >/dev/null 2>&1 &

echo "正在从剪贴板恢复MPV播放..."