const express = require("express");
const app = express();
const axios = require("axios");
const os = require('os');
const fs = require("fs");
const path = require("path");
const { promisify } = require('util');
const exec = promisify(require('child_process').exec);
const { execSync } = require('child_process');

// ------------------------------------------------------------------------------
// 核心配置区 (请根据注释修改变量)
// ------------------------------------------------------------------------------

// 节点或订阅自动上传地址, 需填写部署Merge-sub项目后的首页地址, 例如：https://merge.xxx.com
// 如果不需要自动上传，请保持为空
const UPLOAD_URL = process.env.UPLOAD_URL || '';      

// 项目部署后的实际访问地址 (例如 https://你的app.herokuapp.com 或 https://你的域名.com)
// 用于自动保活和生成订阅链接，建议填写
const PROJECT_URL = process.env.PROJECT_URL || '';    

// 是否开启自动保活 (true/false)，需同时填写 PROJECT_URL 变量才生效
const AUTO_ACCESS = process.env.AUTO_ACCESS || false; 

// 运行目录及临时文件保存目录
const FILE_PATH = process.env.FILE_PATH || './tmp';   

// 自定义订阅路径，例如填写 'mytoken'，则订阅地址为 /mytoken
const SUB_PATH = process.env.SUB_PATH || '';       

// HTTP 服务端口，通常由平台自动分配，无需修改
const PORT = process.env.SERVER_PORT || process.env.PORT || 3000;        

// 节点 UUID，用于 VLESS/VMESS/TROJAN 验证
const UUID = process.env.UUID || ''; 

// 哪吒面板地址 (无端口默认为8008，V0版本需手动带端口，如 nz.abc.com:8008)
const NEZHA_SERVER = process.env.NEZHA_SERVER || '';        

// 哪吒端口 (V1通常为空或443/8443，V0需如实填写)
const NEZHA_PORT = process.env.NEZHA_PORT || '';            

// 哪吒密钥 (V1为Client Secret，V0为Agent密钥)
const NEZHA_KEY = process.env.NEZHA_KEY || '';              

// 【固定隧道配置】Cloudflare Argo 隧道域名，例如 'www.example.com'
// 留空则使用临时隧道 (trycloudflare.com)
const ARGO_DOMAIN = process.env.ARGO_DOMAIN || ''; 

// 【固定隧道配置】Cloudflare Tunnel Token (eyJhIj...) 或 JSON 字符串
// 留空则使用临时隧道
const ARGO_AUTH = process.env.ARGO_AUTH || '';

// 隧道内部通讯端口，通常无需修改
const ARGO_PORT = process.env.ARGO_PORT || 8001;            

// 节点优选 IP 或优选域名 (用于订阅生成)
const CFIP = process.env.CFIP || 'cdns.doon.eu.org';        

// 优选 IP 对应的端口 (通常为 443)
const CFPORT = process.env.CFPORT || 443;                   

// 节点名称前缀
const NAME = process.env.NAME || '';                        

// ------------------------------------------------------------------------------

// 全局变量存储订阅内容，防止启动初期访问404
let globalSubContent = "Node is initializing... Please refresh after 10-30 seconds.";

// 立即注册订阅路由
app.get(`/${SUB_PATH}`, (req, res) => {
  res.set('Content-Type', 'text/plain; charset=utf-8');
  res.send(globalSubContent);
});

// 根路由
app.get("/", function(req, res) {
  res.send(`Hello world! App is running. Mode: ${ARGO_DOMAIN ? 'Fixed Tunnel' : 'Quick Tunnel'}`);
});

// 创建运行文件夹
if (!fs.existsSync(FILE_PATH)) {
  fs.mkdirSync(FILE_PATH, { recursive: true });
}

// 生成随机文件名
function generateRandomName() {
  const characters = 'abcdefghijklmnopqrstuvwxyz';
  let result = '';
  for (let i = 0; i < 6; i++) {
    result += characters.charAt(Math.floor(Math.random() * characters.length));
  }
  return result;
}

const npmName = generateRandomName();
const webName = generateRandomName();
const botName = generateRandomName();
const phpName = generateRandomName();
let npmPath = path.join(FILE_PATH, npmName);
let phpPath = path.join(FILE_PATH, phpName);
let webPath = path.join(FILE_PATH, webName);
let botPath = path.join(FILE_PATH, botName);
let subPath = path.join(FILE_PATH, 'sub.txt');
let listPath = path.join(FILE_PATH, 'list.txt');
let bootLogPath = path.join(FILE_PATH, 'boot.log');
let configPath = path.join(FILE_PATH, 'config.json');

// 如果订阅器上存在历史运行节点则先删除
function deleteNodes() {
  try {
    if (!UPLOAD_URL) return;
    if (!fs.existsSync(subPath)) return;
    let fileContent;
    try {
      fileContent = fs.readFileSync(subPath, 'utf-8');
    } catch { return null; }
    const decoded = Buffer.from(fileContent, 'base64').toString('utf-8');
    const nodes = decoded.split('\n').filter(line => /(vless|vmess|trojan):\/\//.test(line));
    if (nodes.length === 0) return;
    axios.post(`${UPLOAD_URL}/api/delete-nodes`, JSON.stringify({ nodes }), { headers: { 'Content-Type': 'application/json' } }).catch(() => {});
  } catch (err) {}
}

// 生成 config.json
function generateConfig() {
  const config = {
    log: { access: '/dev/null', error: '/dev/null', loglevel: 'none' },
    inbounds: [
      { port: ARGO_PORT, protocol: 'vless', settings: { clients: [{ id: UUID, flow: 'xtls-rprx-vision' }], decryption: 'none', fallbacks: [{ dest: 3001 }, { path: "/vless-argo", dest: 3002 }, { path: "/vmess-argo", dest: 3003 }, { path: "/trojan-argo", dest: 3004 }] }, streamSettings: { network: 'tcp' } },
      { port: 3001, listen: "127.0.0.1", protocol: "vless", settings: { clients: [{ id: UUID }], decryption: "none" }, streamSettings: { network: "tcp", security: "none" } },
      { port: 3002, listen: "127.0.0.1", protocol: "vless", settings: { clients: [{ id: UUID, level: 0 }], decryption: "none" }, streamSettings: { network: "ws", security: "none", wsSettings: { path: "/vless-argo" } }, sniffing: { enabled: true, destOverride: ["http", "tls", "quic"], metadataOnly: false } },
      { port: 3003, listen: "127.0.0.1", protocol: "vmess", settings: { clients: [{ id: UUID, alterId: 0 }] }, streamSettings: { network: "ws", wsSettings: { path: "/vmess-argo" } }, sniffing: { enabled: true, destOverride: ["http", "tls", "quic"], metadataOnly: false } },
      { port: 3004, listen: "127.0.0.1", protocol: "trojan", settings: { clients: [{ password: UUID }] }, streamSettings: { network: "ws", security: "none", wsSettings: { path: "/trojan-argo" } }, sniffing: { enabled: true, destOverride: ["http", "tls", "quic"], metadataOnly: false } },
    ],
    dns: { servers: ["https+local://8.8.8.8/dns-query"] },
    outbounds: [ { protocol: "freedom", tag: "direct" }, {protocol: "blackhole", tag: "block"} ]
  };
  fs.writeFileSync(path.join(FILE_PATH, 'config.json'), JSON.stringify(config, null, 2));
}

function getSystemArchitecture() {
  const arch = os.arch();
  return (arch === 'arm' || arch === 'arm64' || arch === 'aarch64') ? 'arm' : 'amd';
}

function downloadFile(fileName, fileUrl, callback) {
  const writer = fs.createWriteStream(fileName);
  axios({ method: 'get', url: fileUrl, responseType: 'stream' })
    .then(response => {
      response.data.pipe(writer);
      writer.on('finish', () => {
        writer.close();
        try {
            const stats = fs.statSync(fileName);
            if (stats.size < 1024 * 100) { 
                fs.unlinkSync(fileName);
                callback("File too small, likely failed.");
            } else {
                callback(null, fileName);
            }
        } catch (e) { callback(e.message); }
      });
      writer.on('error', err => { fs.unlink(fileName, () => {}); callback(err.message); });
    })
    .catch(err => { callback(err.message); });
}

async function downloadFilesAndRun() {  
  const architecture = getSystemArchitecture();
  const filesToDownload = getFilesForArchitecture(architecture);

  if (filesToDownload.length === 0) return;

  const downloadPromises = filesToDownload.map(fileInfo => {
    return new Promise((resolve, reject) => {
      downloadFile(fileInfo.fileName, fileInfo.fileUrl, (err, filePath) => {
        if (err) reject(err); else resolve(filePath);
      });
    });
  });

  try {
    await Promise.all(downloadPromises);
  } catch (err) {
    console.error(`Download failed: ${err}`);
    return;
  }

  // 授权
  [npmPath, phpPath, webPath, botPath].forEach(f => {
      if (fs.existsSync(f)) fs.chmodSync(f, 0o775);
  });

  // 运行 Nezha (隐藏日志)
  if (NEZHA_SERVER && NEZHA_KEY) {
    if (!NEZHA_PORT) { // V1
      const port = NEZHA_SERVER.includes(':') ? NEZHA_SERVER.split(':').pop() : '';
      const tlsPorts = new Set(['443', '8443', '2096', '2087', '2083', '2053']);
      const configYaml = `
client_secret: ${NEZHA_KEY}
server: ${NEZHA_SERVER}
tls: ${tlsPorts.has(port) ? 'true' : 'false'}
uuid: ${UUID}`;
      fs.writeFileSync(path.join(FILE_PATH, 'config.yaml'), configYaml);
      await exec(`nohup ${phpPath} -c "${FILE_PATH}/config.yaml" >/dev/null 2>&1 &`).catch(() => {});
    } else { // V0
      let NEZHA_TLS = ['443', '8443', '2096', '2087', '2083', '2053'].includes(NEZHA_PORT) ? '--tls' : '';
      await exec(`nohup ${npmPath} -s ${NEZHA_SERVER}:${NEZHA_PORT} -p ${NEZHA_KEY} ${NEZHA_TLS} --skip-conn --skip-procs --disable-auto-update --report-delay 4 >/dev/null 2>&1 &`).catch(() => {});
    }
  }

  // 运行 Xray (隐藏日志)
  await exec(`nohup ${webPath} -c ${FILE_PATH}/config.json >/dev/null 2>&1 &`).catch(() => {});

  // 运行 Cloudflared (根据模式决定是否记录日志)
  if (fs.existsSync(botPath)) {
    let args;
    // 1. 固定隧道 (Token) - 隐藏日志
    if (ARGO_AUTH.match(/^[A-Z0-9a-z=]{120,250}$/)) {
      args = `tunnel --edge-ip-version auto --no-autoupdate --protocol http2 run --token ${ARGO_AUTH} >/dev/null 2>&1`;
    
    // 2. 固定隧道 (JSON) - 隐藏日志
    } else if (ARGO_AUTH.includes('TunnelSecret')) {
       if (ARGO_DOMAIN) {
           fs.writeFileSync(path.join(FILE_PATH, 'tunnel.json'), ARGO_AUTH);
           let tunnelID;
           try {
               tunnelID = JSON.parse(ARGO_AUTH).TunnelID;
           } catch(e) {
               const match = ARGO_AUTH.match(/"TunnelID":"([^"]+)"/);
               if(match) tunnelID = match[1];
           }
           if (tunnelID) {
                const tunnelYaml = `
tunnel: ${tunnelID}
credentials-file: ${path.join(FILE_PATH, 'tunnel.json')}
protocol: http2
ingress:
  - hostname: ${ARGO_DOMAIN}
    service: http://localhost:${ARGO_PORT}
    originRequest:
      noTLSVerify: true
  - service: http_status:404
`;
                fs.writeFileSync(path.join(FILE_PATH, 'tunnel.yml'), tunnelYaml);
                args = `tunnel --edge-ip-version auto --no-autoupdate --protocol http2 run >/dev/null 2>&1`;
           }
       }
       
    // 3. 临时隧道 (Quick Tunnel) - 需要 boot.log 但隐藏控制台输出
    } else {
      args = `tunnel --edge-ip-version auto --no-autoupdate --protocol http2 --logfile ${bootLogPath} --loglevel info --url http://localhost:${ARGO_PORT} >/dev/null 2>&1`;
    }

    if (args) {
        await exec(`nohup ${botPath} ${args} &`).catch(() => {});
    }
  }
  
  await new Promise(r => setTimeout(r, 3000));
}

function getFilesForArchitecture(architecture) {
  const isArm = architecture === 'arm';
  const baseUrl = "https://github.com/cloudflare/cloudflared/releases/latest/download/";
  const botUrl = isArm ? `${baseUrl}cloudflared-linux-arm64` : `${baseUrl}cloudflared-linux-amd64`;
  const webUrl = isArm ? "https://arm64.ssss.nyc.mn/web" : "https://amd64.ssss.nyc.mn/web";

  let files = [
      { fileName: webPath, fileUrl: webUrl },
      { fileName: botPath, fileUrl: botUrl }
  ];

  if (NEZHA_SERVER && NEZHA_KEY) {
      const nUrl = isArm 
        ? "https://github.com/ioiy/nezha-v0.20.5/releases/download/nezha/nezha-agent_arm64"
        : "https://github.com/ioiy/nezha-v0.20.5/releases/download/nezha/nezha-agent_amd64";
      
      if (NEZHA_PORT) {
          files.unshift({ fileName: npmPath, fileUrl: nUrl });
      } else {
          files.unshift({ fileName: phpPath, fileUrl: isArm ? "https://arm64.ssss.nyc.mn/v1" : "https://amd64.ssss.nyc.mn/v1" });
      }
  }
  return files;
}

// 提取域名的核心逻辑
async function extractDomains() {
  let argoDomain = ARGO_DOMAIN;

  // 1. 优先使用固定域名
  if (argoDomain && ARGO_AUTH) {
    console.log(`Using Fixed Domain: ${argoDomain}`);
    await updateGlobalSub(argoDomain);
    return;
  }

  // 2. 尝试读取临时域名 (仅当 boot.log 存在时)
  let retries = 0;
  const maxRetries = 15; 

  const checkLog = async () => {
      if (!fs.existsSync(bootLogPath)) return null;
      const content = fs.readFileSync(bootLogPath, 'utf-8');
      const match = content.match(/https?:\/\/([a-zA-Z0-9-]+\.trycloudflare\.com)/);
      return match ? match[1] : null;
  };

  while (retries < maxRetries) {
      const domain = await checkLog();
      if (domain) {
          console.log(`Found Temp Domain: ${domain}`);
          await updateGlobalSub(domain);
          return;
      }
      retries++;
      await new Promise(r => setTimeout(r, 2000));
  }

  // 3. 兜底
  console.log("Argo Domain not found.");
  const fallbackDomain = PROJECT_URL ? PROJECT_URL.replace(/^https?:\/\//, '') : 'domain-not-found.com';
  await updateGlobalSub(fallbackDomain, "Argo-Failed");
}

// 更新全局订阅内容
async function updateGlobalSub(domain, nameSuffix = "") {
    const metaInfo = execSync('curl -sm 3 https://speed.cloudflare.com/meta | grep -oE "ClientIP.*" || echo "IP-Unknown"', {encoding:'utf-8'});
    const ISP = metaInfo.trim().split(':')[1] ? metaInfo.trim().split(':')[1].trim() : "CF";
    const nodeName = NAME ? `${NAME}-${ISP}${nameSuffix}` : `Node-${ISP}${nameSuffix}`;

    const VMESS = { v: '2', ps: nodeName, add: CFIP, port: CFPORT, id: UUID, aid: '0', scy: 'none', net: 'ws', type: 'none', host: domain, path: '/vmess-argo?ed=2560', tls: 'tls', sni: domain, alpn: '', fp: 'firefox'};
    const subTxt = `
vless://${UUID}@${CFIP}:${CFPORT}?encryption=none&security=tls&sni=${domain}&fp=firefox&type=ws&host=${domain}&path=%2Fvless-argo%3Fed%3D2560#${nodeName}
vmess://${Buffer.from(JSON.stringify(VMESS)).toString('base64')}
trojan://${UUID}@${CFIP}:${CFPORT}?security=tls&sni=${domain}&fp=firefox&type=ws&host=${domain}&path=%2Ftrojan-argo%3Fed%3D2560#${nodeName}
`;
    globalSubContent = Buffer.from(subTxt).toString('base64');
    
    if (UPLOAD_URL) {
        try {
            await axios.post(`${UPLOAD_URL}/api/add-nodes`, JSON.stringify({ nodes: subTxt.split('\n') }), { headers: { 'Content-Type': 'application/json' } });
        } catch (e) {}
    }
}

// 自动访问保活
async function AddVisitTask() {
  if (AUTO_ACCESS && PROJECT_URL) {
    try {
      await axios.post('https://oooo.serv00.net/add-url', { url: PROJECT_URL }, { headers: { 'Content-Type': 'application/json' } });
    } catch (e) {}
  }
}

// 90秒后清理文件，保持环境整洁
function cleanFiles() {
  setTimeout(() => {
    const filesToDelete = [bootLogPath, configPath, webPath, botPath];  
    if (NEZHA_PORT) filesToDelete.push(npmPath);
    else if (NEZHA_SERVER && NEZHA_KEY) filesToDelete.push(phpPath);

    if (process.platform === 'win32') {
      exec(`del /f /q ${filesToDelete.join(' ')} > nul 2>&1`, () => {});
    } else {
      exec(`rm -rf ${filesToDelete.join(' ')} >/dev/null 2>&1`, () => {});
    }
  }, 90000); 
}
cleanFiles();

async function startserver() {
  try {
    deleteNodes();
    generateConfig();
    await downloadFilesAndRun();
    await extractDomains();
    await AddVisitTask();
  } catch (error) {
    console.error('Error:', error);
  }
}

startserver();

app.listen(PORT, () => console.log(`App running on port ${PORT}`));