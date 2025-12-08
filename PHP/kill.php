<?php
header('Content-Type: text/plain; charset=utf-8');

// 1. 自动获取当前用户名
// 尝试多种方式获取，确保准确
$currentUser = '';
if (function_exists('posix_getpwuid') && function_exists('posix_geteuid')) {
    $userInfo = posix_getpwuid(posix_geteuid());
    $currentUser = $userInfo['name'];
}
if (empty($currentUser)) {
    $currentUser = get_current_user();
}
if (empty($currentUser)) {
    $currentUser = trim(shell_exec('whoami'));
}

$currentPid = getmypid(); // 获取当前脚本的PID，防止自杀

echo "========== 智能进程清理工具 (增强版) ==========\n";
echo "当前操作用户(完整): $currentUser\n";
echo "当前脚本PID: $currentPid (保护中)\n\n";

if (empty($currentUser)) {
    die("❌ 错误: 无法识别当前用户名，为了安全已终止操作。\n");
}

echo ">>> 正在扫描并清理属于 [$currentUser] 的后台进程...\n";
echo "------------------------------------------------\n";

// 获取进程列表
$psOutput = [];
// 使用 ps -ef 或 ps aux，这里沿用 ps -eo 格式以便解析
exec('ps -eo user,pid,args'， $psOutput);

$killCount = 0;

foreach ($psOutput as $line) {
    // 跳过表头
    if (strpos($line, 'USER') !== false) continue;

    // 格式化空格
    $line = preg_replace('/\s+/', ' ', trim($line));
    $parts = explode(' ', $line, 3);
    
    if (count($parts) < 3) continue;
    
    $procUser = $parts[0];
    $procPid = $parts[1];
    $procCmd = $parts[2];

    // 核心匹配逻辑：严格匹配当前用户名
    $isMyProcess = false;
    
    // 1. 移除 ps 可能输出的 '+' 号 (例如 yacolo3+ -> yacolo3)
    $cleanProcUser = rtrim($procUser, '+');

    // 2. 匹配逻辑
    if ($procUser === $currentUser) {
        // 情况A: 完全匹配
        $isMyProcess = true;
    } elseif (strlen($cleanProcUser) >= 3 && strpos($currentUser, $cleanProcUser) === 0) {
        // 情况B: 缩写匹配 (例如 yacolo3 是 yacolo356302 的前缀)
        // 且缩写长度至少3位，防止误匹配短用户名
        $isMyProcess = true;
    }

    if ($isMyProcess) {
        // 安全保护 1：绝对不杀自己
        if ($procPid == $currentPid) continue;
        
        // 安全保护 2：不杀 ps 命令本身，防止误报
        if (strpos($procCmd, 'ps -eo') !== false) continue;
        if (strpos($procCmd, 'kill.php') !== false) continue;
        
        // 安全保护 3: 不杀 sshd (防止把自己踢下线，虽然一般没权限)
        if (strpos($procCmd， 'sshd:') !== false) continue;
        if (strpos($procCmd， 'bash') !== false && strpos($procCmd, 'start.sh') === false) {
             // 这是一个可选保护：只保留交互式bash，但杀掉脚本启动的bash。
             // 这里为了清理干净，建议不跳过，除非你在终端里操作怕被踢。
             // 如果你是网页访问，不需要保留bash。
        }

        // 执行查杀
        echo "Kill PID: $procPid ($procUser) | 命令: " 。 substr($procCmd， 0, 50) . "... ";
        
        $out = [];
        $ret = -1;
        exec("kill -9 $procPid 2>&1", $out, $ret);
        
        if ($ret === 0) {
            echo "✅ 成功\n";
            $killCount++;
        } else {
            echo "❌ 失败 (无权限或进程已结束)\n";
        }
    }
}

echo "------------------------------------------------\n";
echo "清理结束，共清理了 $killCount 个属于 [$currentUser] 的进程。\n";
?>
