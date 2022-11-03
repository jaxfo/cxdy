#!/usr/bin/env bash
xy_latest=$(curl -s "https://api.github.com/repos/XTLS/Xray-core/releases/latest" | sed 'y/,/\n/' | grep 'tag_name' | awk -F '"' '{print substr($4,2)}')
test -f xy && xy_current=$(./releases/xy version | awk 'NR==1 {print $2}')
cadyy_latest=$(curl -s "https://api.github.com/repos/caddyserver/caddy/releases/latest" | sed 'y/,/\n/' | grep 'tag_name' | awk -F '"' '{print substr($4,2)}')
test -f caddy && caddy_current=$(./releases/caddy version | awk 'NR==1 {print $2}')
if [[ ${xy_latest} == ${xy_current} ]]
then
    echo 'xy is nothing to do'
else
	git clone https://github.com/XTLS/Xray-core.git
	cd Xray-core && go mod download
	CGO_ENABLED=0 go build -o xy -trimpath -ldflags "-s -w -buildid=" ./main
	mv xy ../releases/xy
	rm -rf ../Xray-core
fi
if [[ ${caddy_latest} == ${caddy_current} ]]
then
    echo 'cddy is nothing to do'
else
	go install github.com/caddyserver/xcaddy/cmd/xcaddy@latest
	xcaddy build latest --output ./releases/caddy
fi
git config user.name github-actions
git config user.email github-actions@github.com
git add .
git commit --allow-empty -m "$(git log -1 --pretty=%s)"
git push
          