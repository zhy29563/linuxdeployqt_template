#! /bin/bash

########################################################################################################################
# 目录
########################################################################################################################
SCT_DIR=$(cd "$(dirname "$0")" && pwd) # scripts
RES_DIR=$(dirname "${SCT_DIR}")        # resources
PJT_DIR=$(dirname "${RES_DIR}")        # repo
OUT_DIR=${PJT_DIR}/outputs             # outputs

########################################################################################################################
# 命令行参数处理
########################################################################################################################
if [ $# -lt 1 ]; then
  echo "usage:"
  echo "  executable app_full_name"
  exit
fi

full_name=$(readlink -f "$1")
echo "full_name=${full_name}"

# 命令行参数左移
shift
other_params=$*
echo "other_params=${other_params}"

# 文件是否存在
if [ ! -e "${full_name}" ] || [ ! -f "${full_name}" ]; then
  echo "$1 is not existed or not a file"
  exit
fi

# 获取文件名
file_name=$(basename "${full_name}")

########################################################################################################################
# 输出目录
########################################################################################################################
if [ ! -e "${OUT_DIR}" ]; then
  mkdir -p "${OUT_DIR}"
fi

DST_DIR=${OUT_DIR}/${file_name}.AppDir
if [ -e "${DST_DIR}" ]; then
  rm -rf "${DST_DIR}"
fi

########################################################################################################################
# 准备封装数据
########################################################################################################################
# 拷贝样例目录结构
cp -r "${RES_DIR}/examples/AppDir" "${DST_DIR}"

# 拷贝可执行文件
cp "${full_name}" "${DST_DIR}/usr/bin"

#  重命名桌面文件
file_name_desktop=${DST_DIR}/usr/share/applications/app.desktop

# modify the context of desktop file
sed -i '/Name=/s/app/'"${file_name}"'/g' "${file_name_desktop}"
sed -i '/Exec=/s/app/'"${file_name}"'/g' "${file_name_desktop}"

########################################################################################################################
# 封装
########################################################################################################################
cd "${OUT_DIR}" || {
  echo "switch to ${OUT_DIR} is failed."
  exit
}

linux_deploy_exe="${RES_DIR}/tools/linuxdeployqt-continuous-x86_64.AppImage"
# linux_deploy_exe="${RES_DIR}/tools/linuxdeployqt-5-x86_64.AppImage"

${linux_deploy_exe} --help
if [ -n "${other_params}" ]; then
  "${linux_deploy_exe}" "${file_name_desktop}" -appimage -always-overwrite -verbose=2 "${other_params}"
else
  "${linux_deploy_exe}" "${file_name_desktop}" -appimage -always-overwrite -verbose=2
fi
