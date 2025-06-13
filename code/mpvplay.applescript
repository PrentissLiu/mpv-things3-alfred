# --- 最终静默版: nohup后台运行 ---

# (第一部分和之前一样，获取文件路径)
tell application "System Events"
    if (name of first process whose frontmost is true) ≠ "Finder" then
        return "请先在Finder中选中文件"
    end if
end tell

tell application "Finder"
    set finderSelectionList to selection
    if (count of finderSelectionList) is 0 then
        return "没有在Finder中选中任何文件"
    end if
    set firstItem to item 1 of finderSelectionList
    set filePath to POSIX path of (firstItem as alias)
end tell

# (第二部分也和之前一样，构建命令的基础部分)
set mpv_path to "/usr/local/bin/mpv" # 确保路径正确
set command_to_run to mpv_path & " --input-ipc-server=/tmp/mpvsocket " & quoted form of filePath


# --- 第三部分：全新的、静默执行的后台命令 ---

# nohup: 让命令在后台持续运行，不受挂断信号影响
# >/dev/null 2>&1: 将所有输出信息都扔进“黑洞”，避免产生日志文件
# &: 让整个命令在后台执行
set final_command to "nohup " & command_to_run & " >/dev/null 2>&1 &"

try
    do shell script final_command
on error errMsg
    return "静默脚本执行错误: " & errMsg
end try