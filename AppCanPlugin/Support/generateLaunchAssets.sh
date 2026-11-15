#!/bin/bash
# Xcode构建阶段在资源编译前执行：把服务器替换后的旧启动PNG同步到源码资源。
# 只读取指定启动图组；缺图立即报错，不跨组回退到模板图片。
set -euo pipefail

fail() {
    printf 'error: AppCan launch screen: %s\n' "$*" >&2
    exit 1
}

[[ $# -eq 4 ]] || fail "usage: generateLaunchAssets.sh <source catalog> <ACELaunchBrand.imageset> <launch group> <device families>"
source_catalog="$1"
output_image_set="$2"
launch_group="$3"
device_families="$4"
families=",${device_families// /},"
[[ -n "$launch_group" && "$launch_group" != */* ]] || fail "invalid LaunchImage group"
[[ "$(basename "$output_image_set")" == ACELaunchBrand.imageset ]] || fail "invalid output image set"
source_group="$source_catalog/$launch_group.launchimage"
[[ -f "$source_group/Contents.json" ]] || fail "missing active group: $launch_group"

has_phone=0
has_pad=0
case "$families" in *,1,*) has_phone=1 ;; esac
case "$families" in *,2,*) has_pad=1 ;; esac
[[ $has_phone -eq 1 || $has_pad -eq 1 ]] || fail "unsupported device family: $device_families"

# 设备族来自宿主配置。仅iPhone应用即使运行在iPad上，也只生成phone资源。
phone_image="$source_group/LaunchImage-800-Portrait-736h@3x.png"
pad_image="$source_group/LaunchImage-700-Portrait@2x~ipad.png"
if [[ $has_phone -eq 1 ]]; then
    [[ -f "$phone_image" ]] || fail "missing iPhone image in $launch_group: $(basename "$phone_image")"
fi
if [[ $has_pad -eq 1 ]]; then
    [[ -f "$pad_image" ]] || fail "missing iPad image in $launch_group: $(basename "$pad_image")"
fi

mkdir -p "$(dirname "$output_image_set")"
work_dir="$(mktemp -d "$(dirname "$output_image_set")/ACELaunchBrand.XXXXXX")"
trap '/bin/rm -rf "$work_dir"' EXIT
image_set="$work_dir/ACELaunchBrand.imageset"
mkdir -p "$image_set"
images=()
if [[ $has_phone -eq 1 ]]; then
    /bin/cp "$phone_image" "$image_set/brand-iphone@3x.png"
    # 复用同一张品牌原图生成2x版本，等比缩小，避免2x/3x设备显示不同构图。
    /usr/bin/sips --resampleHeightWidthMax 1472 "$phone_image" --out "$image_set/brand-iphone@2x.png" >/dev/null
    images+=('    {"idiom":"iphone","scale":"2x","filename":"brand-iphone@2x.png"}')
    images+=('    {"idiom":"iphone","scale":"3x","filename":"brand-iphone@3x.png"}')
fi
if [[ $has_pad -eq 1 ]]; then
    /bin/cp "$pad_image" "$image_set/brand-ipad@2x.png"
    images+=('    {"idiom":"ipad","scale":"2x","filename":"brand-ipad@2x.png"}')
fi
{
    printf '{\n  "images": [\n'
    separator=''
    for entry in "${images[@]}"; do
        printf '%s%s' "$separator" "$entry"
        separator=$',\n'
    done
    printf '\n  ],\n  "info": {"author":"xcode","version":1}\n}\n'
} > "$image_set/Contents.json"

# 每次构建核对源图；内容相同时保留文件时间，方便本地预览和增量编译。
if [[ -d "$output_image_set" ]] && /usr/bin/diff -qr "$image_set" "$output_image_set" >/dev/null; then
    printf 'AppCan launch screen: brand assets unchanged (%s)\n' "$launch_group"
else
    # 此图片组由本脚本独占；设备族改变时清除已不适用的图片。
    /bin/rm -rf "$output_image_set"
    /bin/mv "$image_set" "$output_image_set"
    printf 'AppCan launch screen: updated brand assets (%s, families %s)\n' "$launch_group" "$device_families"
fi
