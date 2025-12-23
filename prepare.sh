#!/bin/bash
id
df -h
free -h
cat /proc/cpuinfo

if [ -d "immortalwrt" ]; then
    echo "repo dir exists"
    cd immortalwrt
    git reset --hard HEAD
    git clean -fd
    git pull || { echo "git pull failed"; exit 1; }
else
    echo "repo dir not exists"
    # git clone -b master --single-branch --filter=blob:none "https://github.com/zzzz0317/immortalwrt" || { echo "git clone failed"; exit 1; }
    git clone -b openwrt-25.12 --single-branch --filter=blob:none "https://github.com/immortalwrt/immortalwrt" || { echo "git clone failed"; exit 1; }
    cd immortalwrt
fi

echo "apply patch for h5000m support"
curl -L https://github.com/immortalwrt/immortalwrt/pull/2166.diff -o support-for-h5000m.diff
patch -p1 < support-for-h5000m.diff

echo "add feeds"
cat feeds.conf.default > feeds.conf
echo "" >> feeds.conf
echo "src-git qmodem https://github.com/FUjr/QModem.git;main" >> feeds.conf
# echo "src-git mtk_openwrt_feed https://git01.mediatek.com/openwrt/feeds/mtk-openwrt-feeds" >> feeds.conf

echo "update files"
rm -rf files
cp -r ../files .

echo "update feeds"
./scripts/feeds update -a || { echo "update feeds failed"; exit 1; }
echo "install feeds"
./scripts/feeds install -a || { echo "install feeds failed"; exit 1; }
./scripts/feeds install -a -f -p qmodem || { echo "install qmodem feeds failed"; exit 1; }

# echo "apply mediatek patch"
# cp -af ./feeds/mtk_openwrt_feed/25.12/files/* .
# for file in $(find ./feeds/mtk_openwrt_feed/25.12/patches-base -name "*.patch" | sort); do patch -f -p1 -i ${file}; done
