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
