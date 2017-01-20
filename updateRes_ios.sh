#!/usr/bin/env bash

VERSION=1.0
USERDOWNLOAD_SUBPATH="userdownload"
IOS_PRE_PATH="res"

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
RES_PATH="$DIR/../../../static/slotshk/universal/$VERSION/app/res/$VERSION"
USER_DOWNLOAD_PATH="$DIR/../../../static/slotshk/universal/$VERSION/app/userdownload/"

RES_LIST=`ls -1 $RES_PATH`
USER_DOWNLOAD_VERSION_LIST=`ls -1 $USER_DOWNLOAD_PATH`

# =====================================================================================
# pref_path sample: 'slotmachine' in 'res/slotmachine/machineicon' 
# ======================================================================================
function updateRESFiles()
{
	local file_list=$1
	local pref_path=$2 

	local fileFullPath
	local child_file_list
	local assets_res_file

	for file in $file_list; do

		fileFullPath=$RES_PATH/$pref_path/$file
		assets_res_file=$IOS_PRE_PATH$pref_path/$file

		if [[ -d $fileFullPath ]]; then
			child_file_list=`ls -1 $fileFullPath`
			removeRESFiles "${child_file_list[@]}" $pref_path/$file

		elif [[ -e $assets_res_file ]]; then
			#rm $assets_res_file
			echo "update: $fileFullPath"
			echo "update: $assets_res_file"
		else			
			echo "**ERROR** res file: $assets_res_file not found."
#	exit 1
		fi
	
	done

}


function update_USER_DOWNLOAD_Files()
{
	local version=$1
	local file_list=$2
	local pref_path=$3

	local fileFullPath
	local child_file_list
	local assets_res_file

	for file in $file_list; do

		fileFullPath=$USER_DOWNLOAD_PATH/$version/$USERDOWNLOAD_SUBPATH/$pref_path/$file
		assets_res_file=$IOS_PRE_PATH$pref_path/$file

		if [[ -d $fileFullPath ]]; then
			child_file_list=`ls -1 $fileFullPath`
			update_USER_DOWNLOAD_Files $version "${child_file_list[@]}" $pref_path/$file

		elif [[ -e $assets_res_file ]]; then
			#rm $assets_res_file
			cp $assets_res_file $fileFullPath
			echo "copy assets_res_file: $assets_res_file"
			echo "to fileFullPath: $fileFullPath"
			echo ""

		else		
			echo "**ERROR** userdownload file: $assets_res_file not found."
#			exit 1
		fi
	
	done

}

echo " ====== updateRESFiles ====== "
updateRESFiles "${RES_LIST[@]}"

echo ""
echo " ====== update_USER_DOWNLOAD_Files ====== "

for machineFolder in $USER_DOWNLOAD_VERSION_LIST; do
	versionFileList=`ls -1 $USER_DOWNLOAD_PATH/$machineFolder/$USERDOWNLOAD_SUBPATH`
	update_USER_DOWNLOAD_Files $machineFolder "${versionFileList[@]}"
done




