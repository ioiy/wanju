# PHP Server Process Manager & Proxy Runner

这是一个基于 PHP 的轻量级服务器进程管理套件，专为 PaaS 平台（如 Serv00、CT8 等）或共享主机环境设计。它允许用户通过 Web 界面或 URL 触发器来管理、启动、监控后台进程（主要是 Sing-box、Cloudflared Argo 隧道和 Nezha 监控）。

## 📂 文件结构说明

| 文件名 | 功能描述 |
| :--- | :--- |
| **index.php** | **核心控制器**。负责路由分发，处理所有的 URL 请求，提供启动、查询、订阅等接口。 |
| **start.sh** | **启动脚本**。包含核心业务逻辑（配置环境变量、下载核心程序、启动 Sing-box/Argo/Nezha）。该脚本内含 Base64 编码的执行逻辑。 |
| **kill.php** | **进程清理工具**。自动识别当前用户，强制终止该用户下所有卡死或旧的后台进程，用于重置环境。 |
| **check.php** | **环境探针**。检测服务器是否支持 PHP `exec`/`system` 函数，以及是否安装了 Python 或 Node.js。 |
| **.htaccess** | **Apache 配置文件**。用于 URL 重写（将请求转发给 `index.php`）以及保护敏感目录（如 `.tmp`）。 |

## 🚀 部署与使用

1. 将所有文件上传至网站根目录（`public_html` 或 `www`）。
2. 确保文件权限设置正确（建议 `.sh` 文件给予 `755` 权限）。
3. 修改 `start.sh` 头部的环境变量（`UUID`, `NEZHA_SERVER` 等）以适配你的配置。

## 🔗 功能接口 (URL 路由)

通过访问 `http://你的域名/后缀` 来使用功能。

> 详细后缀功能列表请参考下文。

## ⚠️ 注意事项

* 本项目依赖 PHP 的 `exec`， `shell_exec`， `passthru` 等函数，请确保主机未禁用这些函数。
* `start.sh` 会自动生成配置文件并保存在 `.tmp` 目录下，请勿手动删除该目录。
* 修改配置后，建议先访问 `/kill.php` 清理进程，再访问 `/start` 重新启动。

域名后缀功能详解基于 index.php 和 .htaccess 的代码逻辑，以下是每个 URL 后缀的具体功能：
域名后缀 (Route)对应功能详细说明/ (根路径)存活检测访问根域名，返回 "Hello world"。用于确认 PHP 解析是否正常，或作为保活监控的端点。
/start启动服务调用 start.sh 脚本。如果服务未运行，它会下载核心、生成配置并启动 Sing-box、Argo 隧道和 Nezha Agent。
/restart重启服务功能同 
/start。在逻辑上通常用于强制重新执行启动脚本（注：建议先执行清理再重启）。
/status状态监控与保活最核心的保活接口。它会检查关键进程（Cloudflared, Sing-box, Nezha）是否在运行。❌ 如果未运行：自动触发启动脚本。✅ 如果运行中：返回 "All services are running"。建议配合定时任务（Cron）每几分钟访问一次此链接。
/list进程列表执行 ps aux 命令，打印当前服务器上所有的进程列表。用于调试和查看系统负载。
/check环境诊断加载 check.php，以图形化界面显示服务器环境信息（PHP 函数禁用情况、Python/Node 版本等）。
/sub获取订阅读取 .tmp/sub.txt 文件内容并输出。这是你的节点订阅链接内容，通常配合 V2rayN 或 Clash 使用。

