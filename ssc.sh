#!/usr/bin/env bash
# 作者：速度与激情小组---Linux部旗下项目（qq群762696893）
# 有任何问题或想一起编写，加qq群联系管理。
#
# 功能：shell脚本合集
# 支持：redhat与centos系列
#
# 地址：github https://github.com/goodboy23/ssc
#       官网   http://www.52wiki.cn/docs/shell/741



#[使用设置]

#输出显示，cn中文，en英文
language=cn

#全局安装目录，所有服务默认安装位置
install_dir=/usr/local
    
#全局日志目录，所有服务默认日志位置
log_dir=/var/log

#edit选项的编辑器，可选择vim或其他
editor=vi



#########消息函数#########

#提示并退出脚本，$1中文，$2英文
print_error() {
    echo
    echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    [[ "$language" == "cn" ]] && echo "错误：$1" || echo "Error：$2"
    echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    echo
    exit 1
}

#消息输出，$1中文，$2英文
print_massage() {
	if [[ "$language" == "cn" ]];then
		echo "$1"
	else
		echo "$2"
	fi
	echo
}



#########基础函数#########

#中文帮助
help_cn() {
	echo "速度与激情小组---Linnux部旗下项目，如有使用问题，请加qq群762696893
当前版本：1.0

install httpd        安装 httpd
remove  httpd        卸载 httpd
get     httpd        离线 httpd 所需要的包
info    httpd        查询 httpd 详细信息
edit	httpd        编辑 httpd 进行自定义设置

update               升级 ssc

list                 列出 支持  的脚本
list    httpd        列出 httpd 相关脚本"
}

#英文帮助
help_en() {
    echo "Speed and passion team---Projects of Linnux Department, if there are any questions, please add qq group 762696893
current version：1.0

install httpd      installation httpd
remove  httpd      Uninstall    httpd
get     httpd      Required     httpd packages for offline
info    httpd      Query        httpd details
edit	httpd      Edit         httpd for custom settings

update             update ssc

list               List supported scripts
list    httpd      List httpd related scripts"
}

#更新
update_ssc() {
    test_root
    test_install git
    git clone https://github.com/goodboy23/ssc.git #下载文件到当前
	[[ -f ssc/conf/install-ssc.sh ]] || print_error "下载失败，请重新更新" "Install Error，please Renew Update"
    ls | grep -v package | xargs rm -rf #将安装包以外文件删除
    rm -rf ssc/package #去除新包的package目录
    mv ssc/* . #将新下载的所有内容复制到当前
    rm -rf ssc
    chmod +x ssc.sh
	[[ $? -eq 0 ]] && print_massage "升级成功！" "update ok!" || print_error "安装失败，请重新更新" "Install Error，please Renew Update"
}

#根据每个和脚本的info函数形成支持的脚本列表
list_generate() {
    [[ -f conf/a.txt ]] && > conf/a.txt #如果生成的时候强制停止，这里则清空一下列表
    
    for i in `ls script/` #将每个脚本的信息都输出找出前3行形成列表
    do
        i=`echo ${i%%.*}`
        a=`bash sai.sh info $i | awk  -F'：' '{print $2}' | sed -n '1p'`
        b=`bash sai.sh info $i | awk  -F'：' '{print $2}' | sed -n '3p'`
        c=`bash sai.sh info $i | awk  -F'：' '{print $2}' | sed -n '5p'`
        echo "$a:$b:$c" >> conf/a.txt
    done
    
    while read list
    do
        name=`echo $list |awk -F: '{print $1}'`
        version=`echo $list |awk -F: '{print $2}'`
        intr=`echo $list |awk -F: '{print $3}'`
        awk 'BEGIN{printf "%-20s%-20s%-20s\n","'"$name"'","'"$version"'","'"$intr"'";}' >> conf/list_${language}.txt
        echo " " >> conf/list_${language}.txt
    done < conf/a.txt
    rm -rf conf/a.txt
}

#对于合集中脚本的操作，安装，卸载，离线包，信息查询，编辑
server() {
    test_version
    test_root

    if [[ -f script/${1}.sh ]];then
        source script/${1}.sh
        if [[ "$1" == "install" ]];then
            print_massage "正在运行${2}脚本，出现错误将会退出，解决后可再次运行。" "The ${2} script is running, an error will exit, and the solution can be run again."
            sleep 3
            script_install
		elif [[ "$1" == "remove" ]];then
			script_remove
        elif [[ "$1" == "get" ]];then
            script_get
        elif [[ "$1" == "info" ]];then   
            script_info
        elif [[ "$1" == "edit" ]];then
            $editor script/${1}.sh
        else
            [[ "$language" == "cn" ]] && help_cn || help_en
        fi
    else
        print_error "没有这个脚本" "Without this service"
    fi
}



#########main主体#########

for i in `ls lib/*` #将函数文件加载到当前
do
    source $i
done

[[ -f conf/list_${language}.txt ]] || list_generate #生成表

if [[ $# -eq 0 ]];then
    [[ "$language" == "cn" ]] && help_cn || help_en
elif [[ $# -eq 1 ]];then
    if [[ "$1" == "list" ]];then
        cat conf/list_${language}.txt
    elif [[ "$1" == "update" ]];then
        update_ssc
	elif [[ "$1" == "installed" ]];then
		cat conf/installed.txt
    fi
elif [[ $# -eq 2 ]];then
    if [[ "$1" == "list" ]];then
        print_massage "$2相关脚本：" "$2 Related script："
		grep "^$2" conf/list_${language}.txt
    else
        server $1 $2
    fi
fi