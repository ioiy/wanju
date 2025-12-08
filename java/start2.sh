#!/bin/bash

# ==============================================================================
# 1. 基础配置 (哪吒监控 & Argo隧道)
# ==============================================================================
export UUID=${UUID:-'b30c06ae-f2f1-44b1-8635-36013a22c688'}     # 节点UUID，也是Vmess/Tuic/Hy2的密码
export NEZHA_SERVER=${NEZHA_SERVER:-''}           # 哪吒面板地址 (无需http://)
export NEZHA_PORT=${NEZHA_PORT:-'443'}                          # 哪吒面板RPC端口 (443/8443等自动开启TLS)
export NEZHA_KEY=${NEZHA_KEY:-''}             # 哪吒Agent密钥
export ARGO_DOMAIN=${ARGO_DOMAIN:-''}            # Argo固定隧道域名
export ARGO_AUTH=${ARGO_AUTH:-''}                    # Argo Token (Json或Token字符串)
export ARGO_PORT=${ARGO_PORT:-''}                          # Argo本地通信端口 (需与隧道后台设置一致)

# ==============================================================================
# 2. 节点优化配置
# ==============================================================================
export CFIP=${CFIP:-'www.csgo.com'}           # Argo节点优选域名 (推荐 www.csgo.com / icook.hk)
export CFPORT=${CFPORT:-'443'}                # Argo节点连接端口
export NAME=${NAME:-'weirdhost-zz'}           # 节点名称前缀

# ==============================================================================
# 3. 直连节点配置 (重要！！！)
# ==============================================================================
# [域名设置] (选填)
# 填入域名：直连节点将使用该域名 (推荐，Serv00防墙必备)
# 留空不填：脚本会自动获取服务器公网 IP
export SERVER_DOMAIN='join.wrd.kr'

# [端口设置]
# 默认值: 40000 / 50000 / 60000
# 逻辑说明: 如果保持默认值，脚本【不会】输出对应的节点 (防止报错/封号)。
#          只有改为你实际申请的端口，才会生成并输出对应节点。
export TUIC_PORT=${TUIC_PORT:-'40000'}        # 请修改为你申请的 UDP 端口
export HY2_PORT=${HY2_PORT:-'50000'}          # 请修改为你申请的 UDP 端口
export REALITY_PORT=${REALITY_PORT:-'60000'}  # 请修改为你申请的 TCP 端口

# ==============================================================================
# 4. 其他系统配置
# ==============================================================================
export FILE_PATH=${FILE_PATH:-'./world'}      # 临时文件存放目录
export GAME_FILE=${GAME_FILE:-'LICENSE.jar'}  # 伪装的游戏启动文件 (保活关键)
export CHAT_ID=${CHAT_ID:-''}                 # Telegram 通知 ID (选填)
export BOT_TOKEN=${BOT_TOKEN:-''}             # Telegram Bot Token (选填)
export UPLOAD_URL=${UPLOAD_URL:-''}           # 节点自动上传接口 (选填)

# ==============================================================================
# 在此处下方粘贴你的加密运行命令: echo "..." | base64 -d | bash
# ==============================================================================
 echo "IyEvYmluL2Jhc2gKCiMgLS0tIOWIneWni+WMliAtLS0KRj0iJHtGSUxFX1BBVEg6LS9hcHB9IgpbICEgLWQgIiRGIiBdICYmIG1rZGlyIC1wICIkRiIKcm0gLXJmIGJvb3QubG9nIGNvbmZpZy5qc29uIHR1bm5lbC5qc29uIHR1bm5lbC55bWwgIiRGL3N1Yi50eHQiICIkRi9saXN0LnR4dCIgY2VydC5wZW0gcHJpdmF0ZS5rZXkKcGtpbGwgLWYgInNiIHJ1biI7IHBraWxsIC1mICJib3QgdHVubmVsIjsgcGtpbGwgLWYgImFnZW50IC1zIgoKIyAtLS0gQXJnbyDphY3nva4gLS0tCmlmIFtbIC1uICIkQVJHT19BVVRIIiAmJiAtbiAiJEFSR09fRE9NQUlOIiBdXTsgdGhlbgogICAgaWYgW1sgIiRBUkdPX0FVVEgiID1+IFR1bm5lbFNlY3JldCBdXTsgdGhlbgogICAgICAgIGVjaG8gIiRBUkdPX0FVVEgiID4gdHVubmVsLmpzb24KICAgICAgICBlY2hvICJ0dW5uZWw6ICQoY3V0IC1kJyInIC1mMTIgPDw8ICIkQVJHT19BVVRIIikKY3JlZGVudGlhbHMtZmlsZTogL2FwcC90dW5uZWwuanNvbgpwcm90b2NvbDogaHR0cDIKaW5ncmVzczoKICAtIGhvc3RuYW1lOiAkQVJHT19ET01BSU4KICAgIHNlcnZpY2U6IGh0dHA6Ly9sb2NhbGhvc3Q6JEFSR09fUE9SVAogICAgb3JpZ2luUmVxdWVzdDoKICAgICAgbm9UTFNWZXJpZnk6IHRydWUKICAtIHNlcnZpY2U6IGh0dHBfc3RhdHVzOjQwNCIgPiB0dW5uZWwueW1sCiAgICBmaQpmaQoKIyAtLS0g5LiL6L2957uE5Lu2IC0tLQpBUkNIPSQodW5hbWUgLW0pCmNhc2UgIiRBUkNIIiBpbgogICAgImFybSJ8ImFybTY0InwiYWFyY2g2NCIpIEJBU0U9Imh0dHBzOi8vYXJtNjQuc3Nzcy5ueWMubW4iIDs7CiAgICAqKSBCQVNFPSJodHRwczovL2FtZDY0LnNzc3MubnljLm1uIiA7Owplc2FjCndnZXQgLXEgLU8gc2IgIiRCQVNFL3NiIiAmJiBjaG1vZCAreCBzYgp3Z2V0IC1xIC1PIGJvdCAiJEJBU0UvYm90IiAmJiBjaG1vZCAreCBib3QKaWYgWyAtbiAiJE5FWkhBX1NFUlZFUiIgXTsgdGhlbgogICAgd2dldCAtcSAtTyBhZ2VudCAiaHR0cHM6Ly9naXRodWIuY29tL2lvaXkvbmV6aGEtdjAuMjAuNS9yZWxlYXNlcy9kb3dubG9hZC9uZXpoYS9uZXpoYS1hZ2VudF9hbWQ2NCIgJiYgY2htb2QgK3ggYWdlbnQKZmkKCiMgLS0tIOeUn+aIkOivgeS5piAtLS0Kb3BlbnNzbCBlY3BhcmFtIC1nZW5rZXkgLW5hbWUgcHJpbWUyNTZ2MSAtb3V0IHByaXZhdGUua2V5Cm9wZW5zc2wgcmVxIC1uZXcgLXg1MDkgLWRheXMgMzY1MCAta2V5IHByaXZhdGUua2V5IC1vdXQgY2VydC5wZW0gLXN1YmogIi9DTj1iaW5nLmNvbSIKIyBSZWFsaXR5IEtleQpSX09VVD0kKC4vc2IgZ2VuZXJhdGUgcmVhbGl0eS1rZXlwYWlyKQpQSz0kKGVjaG8gIiRSX09VVCIgfCBhd2sgJy9Qcml2YXRlS2V5Oi8ge3ByaW50ICQyfScpClBGPSQoZWNobyAiJFJfT1VUIiB8IGF3ayAnL1B1YmxpY0tleTovIHtwcmludCAkMn0nKQoKIyAtLS0g55Sf5oiQIENvbmZpZyAtLS0KY2F0ID4gY29uZmlnLmpzb24gPDwgRU9GCnsKICAibG9nIjogeyJkaXNhYmxlZCI6IHRydWUsICJsZXZlbCI6ICJ3YXJuIn0sCiAgImluYm91bmRzIjogWwogICAgeyJ0YWciOiAidm1lc3MtaW4iLCAidHlwZSI6ICJ2bWVzcyIsICJsaXN0ZW4iOiAiOjoiLCAibGlzdGVuX3BvcnQiOiAke0FSR09fUE9SVH0sICJ1c2VycyI6IFt7InV1aWQiOiAiJHtVVUlEfSJ9XSwgInRyYW5zcG9ydCI6IHsidHlwZSI6ICJ3cyIsICJwYXRoIjogIi92bWVzcy1hcmdvIiwgImVhcmx5X2RhdGFfaGVhZGVyX25hbWUiOiAiU2VjLVdlYlNvY2tldC1Qcm90b2NvbCJ9fSwKICAgIHsidGFnIjogInR1aWMtaW4iLCAidHlwZSI6ICJ0dWljIiwgImxpc3RlbiI6ICI6OiIsICJsaXN0ZW5fcG9ydCI6ICR7VFVJQ19QT1JUOi00MDAwMH0sICJ1c2VycyI6IFt7InV1aWQiOiAiJHtVVUlEfSIsICJwYXNzd29yZCI6ICJhZG1pbiJ9XSwgImNvbmdlc3Rpb25fY29udHJvbCI6ICJiYnIiLCAidGxzIjogeyJlbmFibGVkIjogdHJ1ZSwgImFscG4iOiBbImgzIl0sICJjZXJ0aWZpY2F0ZV9wYXRoIjogImNlcnQucGVtIiwgImtleV9wYXRoIjogInByaXZhdGUua2V5In19LAogICAgeyJ0YWciOiAiaHkyLWluIiwgInR5cGUiOiAiaHlzdGVyaWEyIiwgImxpc3RlbiI6ICI6OiIsICJsaXN0ZW5fcG9ydCI6ICR7SFkyX1BPUlQ6LTUwMDAwfSwgInVzZXJzIjogW3sicGFzc3dvcmQiOiAiJHtVVUlEfSJ9XSwgIm1hc3F1ZXJhZGUiOiAiaHR0cHM6Ly9iaW5nLmNvbSIsICJ0bHMiOiB7ImVuYWJsZWQiOiB0cnVlLCAiYWxwbiI6IFsiaDMiXSwgImNlcnRpZmljYXRlX3BhdGgiOiAiY2VydC5wZW0iLCAia2V5X3BhdGgiOiAicHJpdmF0ZS5rZXkifX0sCiAgICB7InRhZyI6ICJ2bGVzcy1pbiIsICJ0eXBlIjogInZsZXNzIiwgImxpc3RlbiI6ICI6OiIsICJsaXN0ZW5fcG9ydCI6ICR7UkVBTElUWV9QT1JUOi02MDAwMH0sICJ1c2VycyI6IFt7InV1aWQiOiAiJHtVVUlEfSIsICJmbG93IjogInh0bHMtcnByeC12aXNpb24ifV0sICJ0bHMiOiB7ImVuYWJsZWQiOiB0cnVlLCAic2VydmVyX25hbWUiOiAid3d3Lm5hemh1bWkuY29tIiwgInJlYWxpdHkiOiB7ImVuYWJsZWQiOiB0cnVlLCAiaGFuZHNoYWtlIjogeyJzZXJ2ZXIiOiAid3d3Lm5hemh1bWkuY29tIiwgInNlcnZlcl9wb3J0IjogNDQzfSwgInByaXZhdGVfa2V5IjogIiR7UEt9IiwgInNob3J0X2lkIjogWyIiXX19fQogIF0sCiAgIm91dGJvdW5kcyI6IFt7InR5cGUiOiAiZGlyZWN0IiwgInRhZyI6ICJkaXJlY3QifV0KfQpFT0YKCiMgLS0tIOWQr+WKqOacjeWKoSAtLS0Kbm9odXAgLi9zYiBydW4gLWMgY29uZmlnLmpzb24gPi9kZXYvbnVsbCAyPiYxICYKaWYgW1sgIiRBUkdPX0FVVEgiID1+IFR1bm5lbFNlY3JldCBdXTsgdGhlbgogICAgbm9odXAgLi9ib3QgdHVubmVsIC0tZWRnZS1pcC12ZXJzaW9uIGF1dG8gLS1jb25maWcgdHVubmVsLnltbCBydW4gPi9kZXYvbnVsbCAyPiYxICYKZWxpZiBbWyAtbiAiJEFSR09fQVVUSCIgXV07IHRoZW4KICAgIG5vaHVwIC4vYm90IHR1bm5lbCAtLWVkZ2UtaXAtdmVyc2lvbiBhdXRvIC0tbm8tYXV0b3VwZGF0ZSAtLXByb3RvY29sIGh0dHAyIHJ1biAtLXRva2VuICIkQVJHT19BVVRIIiA+L2Rldi9udWxsIDI+JjEgJgpmaQppZiBbIC1uICIkTkVaSEFfU0VSVkVSIiBdOyB0aGVuCiAgICBbWyAiJE5FWkhBX1BPUlQiID1+ICg0NDN8ODQ0M3wyMDk2fDIwNTN8MjA4N3wyMDgzKSBdXSAmJiBUPSItLXRscyIgfHwgVD0iIgogICAgbm9odXAgLi9hZ2VudCAtcyAiJHtORVpIQV9TRVJWRVJ9OiR7TkVaSEFfUE9SVH0iIC1wICIke05FWkhBX0tFWX0iICRUID4vZGV2L251bGwgMj4mMSAmCmZpCgojIC0tLSDnlJ/miJDoioLngrnpk77mjqUgLS0tCnNsZWVwIDMKSVA9JChjdXJsIC1zIC0tbWF4LXRpbWUgMiBpcHY0LmlwLnNiIHx8IGVjaG8gIklQLUVycm9yIikKIyDliKTmlq3kvb/nlKjln5/lkI3ov5jmmK9JUAppZiBbIC1uICIkU0VSVkVSX0RPTUFJTiIgXTsgdGhlbiBIT1NUPSIkU0VSVkVSX0RPTUFJTiI7IGVsc2UgSE9TVD0iJElQIjsgZmkKCiMgVk1lc3MgKEFyZ28pClZKPSJ7XCJ2XCI6XCIyXCIsXCJwc1wiOlwiJHtOQU1FfS1BcmdvXCIsXCJhZGRcIjpcIiR7Q0ZJUH1cIixcInBvcnRcIjpcIiR7Q0ZQT1JUfVwiLFwiaWRcIjpcIiR7VVVJRH1cIixcImFpZFwiOlwiMFwiLFwic2N5XCI6XCJub25lXCIsXCJuZXRcIjpcIndzXCIsXCJ0eXBlXCI6XCJub25lXCIsXCJob3N0XCI6XCIke0FSR09fRE9NQUlOfVwiLFwicGF0aFwiOlwiL3ZtZXNzLWFyZ28/ZWQ9MjA0OFwiLFwidGxzXCI6XCJ0bHNcIixcInNuaVwiOlwiJHtBUkdPX0RPTUFJTn1cIixcImFscG5cIjpcIlwiLFwiZnBcIjpcIlwifSIKZWNobyAidm1lc3M6Ly8kKGVjaG8gLW4gIiRWSiIgfCBiYXNlNjQgLXcwKSIgPj4gIiRGL2xpc3QudHh0IgoKIyDnm7Tov57oioLngrkgKOerr+WPo+S4jeS4uum7mOiupOWAvOaXtuaJjei+k+WHuikKWyAiJHtUVUlDX1BPUlQ6LTQwMDAwfSIgIT0gIjQwMDAwIiBdICYmIGVjaG8gInR1aWM6Ly8ke1VVSUR9OmFkbWluQCR7SE9TVH06JHtUVUlDX1BPUlQ6LTQwMDAwfT9zbmk9YmluZy5jb20mYWxwbj1oMyZjb25nZXN0aW9uX2NvbnRyb2w9YmJyJmFsbG93X2luc2VjdXJlPTEjJHtOQU1FfS1UdWljIiA+PiAiJEYvbGlzdC50eHQiClsgIiR7SFkyX1BPUlQ6LTUwMDAwfSIgIT0gIjUwMDAwIiBdICYmIGVjaG8gImh5c3RlcmlhMjovLyR7VVVJRH1AJHtIT1NUfToke0hZMl9QT1JUOi01MDAwMH0vP3NuaT1iaW5nLmNvbSZhbHBuPWgzJmluc2VjdXJlPTEjJHtOQU1FfS1IeTIiID4+ICIkRi9saXN0LnR4dCIKWyAiJHtSRUFMSVRZX1BPUlQ6LTYwMDAwfSIgIT0gIjYwMDAwIiBdICYmIGVjaG8gInZsZXNzOi8vJHtVVUlEfUAke0hPU1R9OiR7UkVBTElUWV9QT1JUOi02MDAwMH0/ZW5jcnlwdGlvbj1ub25lJmZsb3c9eHRscy1ycHJ4LXZpc2lvbiZzZWN1cml0eT1yZWFsaXR5JnNuaT13d3cubmF6aHVtaS5jb20mZnA9Y2hyb21lJnBiaz0ke1BGfSZ0eXBlPXRjcCZoZWFkZXJUeXBlPW5vbmUjJHtOQU1FfS1SZWFsaXR5IiA+PiAiJEYvbGlzdC50eHQiCgojIC0tLSDovpPlh7rkuI7muIXnkIYgLS0tCmJhc2U2NCAtdzAgIiRGL2xpc3QudHh0IiA+ICIkRi9zdWIudHh0IgplY2hvIC1lICJcbj09PSBOb2RlIExpc3QgKEFkZHI6ICRIT1NUKSA9PT1cbiIKY2F0ICIkRi9saXN0LnR4dCIKZWNobyAtZSAiXG49PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09XG4iCgplY2hvICJDbGVhbmluZyB1cCBpbiAxNSBzZWNvbmRzLi4uIgpzbGVlcCAxNQpybSAtcmYgYm9vdC5sb2cgY29uZmlnLmpzb24gdHVubmVsLmpzb24gdHVubmVsLnltbCBjZXJ0LnBlbSBwcml2YXRlLmtleSAiJEYvbGlzdC50eHQiCmNsZWFy" | base64 -d | bash
chmod +x ${GAME_FILE} && java -jar ${GAME_FILE}
