#!/bin/bash

# Long term garbage collection station(Please use absolute path)
TRASH_DIR="/home/.trash"
# The maximum capacity allowed for the garbage bin (unit: byte) 1M=1024*1024 1G=1M*1024
MAXCAPACITY=$((15*1024*1024*1024)) #  (default 15G)
# Maximum single file, exceeding which cannot enter the recycle bin and will be directly deleted (unit: byte) 
MAXSIZE=$((4*1024*1024*1024)) # (default 4G)



# Prohibited deletion of directories 
BANLIST=(
"/"
"/bin"
"/boot"
"/dev"
"/etc"
"/home"
"/home/$USER"
"/home/$SUDO_USER"
"/init"
"/lib"
"/lib32"
"/lib64"
"/libx32"
"/media"
"/proc"
"/root"
"/sbin"
"/sys"
"/usr"
"/var"
"${TRASH_DIR}"
)




function ERROR() {
    EXITCODE=$1
    case ${EXITCODE} in
        0)
            # Success
            return 0
        ;;
        1)
            echo -e "Error: Operation not permitted, Exit Code: ${EXITCODE}"
            exit 1
        ;;
        2)
            echo -e "Error: No such file or directory, Exit Code: ${EXITCODE}"
            exit 2
        ;;
        21)
            echo -e "Error: Is a directory, Exit Code: ${EXITCODE}"
            exit 21
        ;;
        *)
            echo -e "Error: Permission denied or Unknown error, Exit Code: ${EXITCODE}"
            exit -1
        ;;
    esac
}




RMBIN=""
function findRm(){
    if [ -e "/usr/bin/RM" ]; then
        RMBIN="/usr/bin/RM"
        return
    elif [ -e "/bin/RM" ]; then
        RMBIN="/bin/RM"    
        return
    elif [ -e "/usr/bin/rm" ]; then
        RMBIN="/usr/bin/rm"
        return
    elif [ -e "/bin/rm" ]; then
        RMBIN="/bin/rm"
        return
    else
        echo "Warn: Not found /usr/bin/rm or /bin/rm"
    fi
}



# Check if the garbage bin exists
function checkTrashDir(){
    user=""
    if [ ! "${USER}" = "root" ];then
        user=${USER}
    elif [[ "${USER}" = "root" && ! ${SUDO_USER} = "root" ]];then
        user=${SUDO_USER}
    else
        echo "Create the garbage collector using the normal user's sudo instead of logging in to root !"
        exit -1       
    fi
    
    if [[ ! -d "$TRASH_DIR" ]]; then
        echo "Trash DIR: ${TRASH_DIR}"
        echo "Trash directory does not exist. Try creating..."
        mkdir -p "$TRASH_DIR" >>/dev/null 2>&1
        ERROR $?
        
        chown ${user}:${user} ${TRASH_DIR}
        ERROR $?
        echo "Trash directory created successfully."            
    fi
}





# priority level
PARAMETER_f=false # 0.7

PARAMETER_i=false # 0.6
PARAMETER_I=false # 0.5

PARAMETER_r=false # 0.4
# PARAMETER_R=false # 0.4

PARAMETER_d=false # 0.3
PARAMETER_b=false # 0.2
PARAMETER_v=false # 0.1

PARAMETER_install=false  # 1.1 and exit
PARAMETER_safe_install=false  # 1.2 and exit
PARAMETER_uninstall=false  # 1.3 and exit
PARAMETER_help=false  # 1 and exit
PARAMETER_version=false # 0.9 and exit
PARAMETER_clean=false # 0.8 and exit






FILE_FOLDER_LIST=()

function enableOption(){
    for arg in "$@"; do
        arg="${arg//force/f}"
        arg="${arg//recursive/r}"
        arg="${arg//dir/d}"
        arg="${arg//verbose/v}"
                    
        if [ "$arg" == "install" ]; then
            PARAMETER_install=true
            continue
        fi

        if [ "$arg" == "uninstall" ]; then
            PARAMETER_uninstall=true
            continue
        fi

        if [ "$arg" == "help" ]; then
            PARAMETER_help=true
            continue
        fi
        
        if [ "$arg" == "version" ]; then
            PARAMETER_version=true
            continue
        fi        
        
        if [ "$arg" == "clean" ]; then
            PARAMETER_clean=true
            continue
        fi

        if [[ $arg == *"f"* ]]; then
            PARAMETER_f=true
        fi 

        if [[ $arg == *"i"* ]]; then
            PARAMETER_i=true
        fi     

        if [[ $arg == *"I"* ]]; then
            PARAMETER_I=true
        fi

        if [[ $arg == *"r"* ]]; then
            PARAMETER_r=true
        fi

        if [[ $arg == *"R"* ]]; then
            PARAMETER_r=true
        fi

        if [[ $arg == *"d"* ]]; then
            PARAMETER_d=true
        fi

        if [[ $arg == *"v"* ]]; then
            PARAMETER_v=true
        fi

        if [[ $arg == *"b"* ]]; then
            PARAMETER_b=true
        fi
    done
}


function help(){
cat <<-EOF
Usage: rm [OPTION]... [FILE]...
Remove (unlink) the FILE(s).

    -f, --force           ignore nonexistent files and arguments, never prompt
    -i                    prompt before every removal
    -I                    prompt once before removing more than three files
    -r, -R, --recursive   remove directories and their contents recursively
    -d, --dir             remove empty directories
    -b,                   put file to trash instead of rm -rf file
    -v, --verbose         explain what is being done
        --help     display this help and exit
        --version  output version information and exit
    --install              Use rm.sh instead of the rm command, but keep /bin/rm or /usr/bin/rm
    --safe-install         Use rm.sh to completely replace rm
    --uninstall           Cancel the use of rm.sh instead of rm
    --clean              Empty the trash dir.

To remove a file whose name starts with a '-', for example '-foo' or '--foo',
use one of these commands:
    rm ./-foo      
    rm ./--foo 

BY ThreeDays
EOF
}


function clean(){
    DIRS=("${TRASH_DIR}")
    if [ ${PARAMETER_f} = "true" ];then
        "${RMBIN//RM/rm}.bak" -rf ${TRASH_DIR}/* 
        ERROR $?
    else
        if [ -d "${TRASH_DIR}" ]; then
            echo -e "Trash Dir: ${TRASH_DIR}"
            echo -en "Are you sure to clean it?[y|n]: " ""
            read op
            op="${op// /}"
            case $op in
                y|Y)
                    if [ ! "${RMBIN}" == "" ]; then
                        echo "Execute: del ${TRASH_DIR}/*"
                        "${RMBIN//RM/rm}.bak" -rf ${TRASH_DIR}/* 
                        ERROR $?
                    else
                        echo "Warn: Not found /usr/bin/rm or /bin/rm"
                        exit 1
                    fi
                ;;
                *)
                    echo "Not doing anything, EXIT..."
                    continue
                    ;;
            esac
        else
            echo "The trash dir is empty..."
        fi
    fi
}


function upddateCapacitySize(){
    # 对于超过MAXSIZE的，不执行
    capacity_size=$(du -s -b ${TRASH_DIR} | awk '{print $1}') 
    config_file=$1
    echo "${capacity_size}" > ${config_file}
}


count=0
# Determine if the parameter is a valid command
function judgingParameters(){
    for Parameter in "${args[@]}"; do
        # option
        if [ "${Parameter:0:1}" = "-" ]; then
            string="${Parameter//uninstall/}"
 
            string="${string//force/}"
            string="${string//recursive/}"
            string="${string//dir/}"
            string="${string//verbose/}"
            
            string="${string//safe-install/}"
            string="${string//install/}"            
            string="${string//help/}"
            string="${string//version/}"
            string="${string//clean/}"
            string=${string//[- fiIrRdbv]/}
            # string="${string:1}"

            if [ -z "${string}" ]; then
                if [ "--safe-install" = ${Parameter} ];then
                    PARAMETER_safe_install=true
                    continue
                fi
                enableOption ${Parameter//[ -]/}
            else
                echo "rm: unrecognized option '${Parameter}'"
                echo "Try 'rm --help' for more information."
                exit 1
            fi
        else
            if [ "${Parameter:0:2}" = ".." ]; then
                Parameter="$(readlink -f ${Parameter})"
            fi
            # echo "Parameter: $Parameter"
            for arg in "${BANLIST[@]}"; do
                flag=flag
                if [[ "${PWD}" == "/" ]];then
                    if [[ "${Parameter}" == "${arg//\//}" || "${Parameter}" == "." || "${Parameter}" == ".${arg}" || "${Parameter}" == ".${arg}/" || "${Parameter}" == "${arg}" || "${Parameter}" == "${arg}/" ]]; then
                        flag=true
                    fi
                    if [[ "${Parameter}" == "..${arg}" || "${Parameter}" == "..${arg}/" ]]; then
                        flag=true
                    fi
                else
                    if [[ "${Parameter}" == "${arg}" || "${Parameter}" == "${arg}/" ]]; then
                        flag=true
                    fi
                    if [[ "${Parameter}" == "../${USER}" || "${Parameter}" == "..${arg}" || "${Parameter}" == "..${arg}/" ]]; then
                        flag=true
                    fi
                fi

                if [ "${flag}" = "true" ]; then
                    echo "Error: Do not delete ${Parameter}"
                    echo "Warn: ===>>> This is an important directory for the system !!! <<<==="
                    echo "Warn: Your current location: ${PWD}"
                    echo "Warn: If you want to delete, please use: "
                    echo "      ${RMBIN//RM/rm}.bak -rf ${Parameter}"
                    exit 1
                fi
            done
            num=$(echo "$Parameter" | grep -o '/' | wc -l)
            if [ $num = 2 ];then
                count+=1
            fi
            if [ $count -ge 3 ];then
                echo "Warn: Detected deletion of a large number of root secondary files, script refused to execute !"
                echo "Warn: Do not use rm -rf /$(echo "$Parameter" | cut -d'/' -f2)/*"
                echo "Warn: You can delete it individually, please use: "
                echo -e "for example:\n      rm -rf /$(echo "$Parameter" | cut -d'/' -f2)/foo"
                exit -1
            fi
            FILE_FOLDER_LIST+=("${Parameter}")
        fi
    done
    FILE_FOLDER_LIST=($(printf "%s\n" "${FILE_FOLDER_LIST[@]}" | sort -u))
}


RMLIST=("/usr/bin/RM" "/bin/RM" "/usr/bin/rm" "/bin/rm")
function rmBackup(){
    rmbin=""
    for item in ${RMLIST[@]};
    do
        if [ -e "${item}" ]; then
            version="$(${item} --version)"
            if [[ ! $RMBIN == *"ThreeDays"* ]]; then
                rmbin=${item}
            fi
            break
        fi
    done

    if [ -z $rmbin ];then
        echo "Warn: Not found /usr/bin/rm or /bin/rm"
        exit -1
    fi

    # cp rm --> rm.bak
    if [ ! -f "${rmbin//RM/rm}.bak" ]; then
        echo "Try: cp -rf ${rmbin} "${rmbin//RM/rm}.bak""
        cp -rf ${rmbin} "${rmbin//RM/rm}.bak"
        ERROR $?
    fi
    
    
    script_path=$(readlink -f "$0")
    if [ ! "${script_path}" = "/bin/rm.sh" ];then
        if [ -f "/bin/rm.sh" ];then
            echo "Try: del /bin/rm.sh"
            "${RMBIN//RM/rm}.bak" -rf "/bin/rm.sh"
            ERROR $?
        fi

        echo "Try: cp -rf ${script_path} /bin/"
        cp -rf ${script_path} /bin/
        ERROR $?
    fi    
}

function safeInstallScript(){
    rmBackup
    for item in ${RMLIST[@]};
    do
        if [ -f ${item} ];then
            echo "Try: del ${item}"
            "${RMBIN//RM/rm}.bak" -rf ${item} 
            ERROR $?
        fi
    done
    chmod +x /bin/rm.sh
    ERROR $?      

    # cp rm.bak --> RM
    echo "Try: cp -rf ${RMBIN//RM/rm}.bak ${RMBIN//rm/RM}"
    cp -rf "${RMBIN//RM/rm}.bak" "${RMBIN//rm/RM}"
    ERROR $?

    # cp rm.sh -> rm 
    echo "Try: link /bin/rm.sh --> ${RMBIN//RM/rm}"
    ln -s "/bin/rm.sh" ${RMBIN//RM/rm}
    ERROR $?

    # alias rm.sh as rm
    profile=$(cat /etc/profile | grep "alias rm=/bin/rm.sh")
    if [ -z "${profile}" ];then
        echo "Execute: echo 'alias rm=/bin/rm.sh' | tee -a /etc/profile"
        echo "alias rm=/bin/rm.sh" | tee -a /etc/profile
        ERROR $?
    fi
}

function installScript(){
    rmBackup
    for item in ${RMLIST[@]};
    do
        if [ -f ${item} ];then
            echo "Try: del ${item}"
            "${RMBIN//RM/rm}.bak" -rf ${item} 
            ERROR $?
        fi
    done
    chmod +x /bin/rm.sh
    ERROR $?      

    # cp rm.bak --> rm
    echo "Try: cp -rf ${RMBIN//RM/rm}.bak ${RMBIN//RM/rm}"
    cp -rf "${RMBIN//RM/rm}.bak" "${RMBIN//RM/rm}"
    ERROR $?    

    # alias rm.sh as rm
    profile=$(cat /etc/profile | grep "alias rm=/bin/rm.sh")
    if [ -z "${profile}" ];then
        echo "Execute: echo 'alias rm=/bin/rm.sh' | tee -a /etc/profile"
        echo "alias rm=/bin/rm.sh" | tee -a /etc/profile
        ERROR $?
    fi
}

function uninstallScript(){
    rmBackup
    for item in ${RMLIST[@]};
    do
        if [ ${item} = "/bin/rm.sh" ];then
            continue
        fi
        if [ -f ${item} ];then
            echo "Try: del ${item}"
            "${RMBIN//RM/rm}.bak" -rf ${item} 
            ERROR $?
        fi
    done

    # rm.bak --> rm
    echo "Try: cp -rf ${RMBIN//RM/rm}.bak ${RMBIN//RM/rm}"
    cp -rf "${RMBIN//RM/rm}.bak" "${RMBIN//RM/rm}"
    ERROR $?    

    # alsit rm as rm
    echo "Execute: sudo sed -i 's|alias rm=/bin/rm.sh||g' /etc/profile"
    sed -i 's|alias rm=/bin/rm.sh||g' /etc/profile >>/dev/null 2>&1
    ERROR $?
    echo "Warn: Restarting the terminal takes effect !"    
}



function askAbout(){
        arg=$1
        echo -en "remove '$arg'?[y|n]: " ""
        read op
        op="${op// /}"
        case $op in
            y|Y)
                return 0
            ;;
            *)
                return -1
                ;;
        esac
}

function executeRm(){
    config_file="${TRASH_DIR}/size"
    config_file="${config_file//\/\//\/}"
    if [ -e $config_file ];then
        size="$(cat $config_file)"
        if [[ "$size" =~ ^[0-9]+$ ]]; then
            if [ $size -gt $MAXCAPACITY ];then
                echo "Warn: The capacity of the garbage collection station has reached its maximum limit ! Exit..."
                exit -1
            fi
        else
            echo "0" > $config_file
        fi
    fi

    if [ "${PARAMETER_uninstall}" = "true" ]; then
        uninstallScript
        exit 0
    fi

    if [ "${PARAMETER_safe_install}" = "true" ]; then
        safeInstallScript
        exit 0
    fi


    if [ "${PARAMETER_install}" = "true" ]; then
        installScript
        exit 0
    fi

    if [ "${PARAMETER_help}" = "true" ]; then
        help
        exit 0
    fi

    if [ "${PARAMETER_version}" = "true" ]; then
        echo "rm.sh-0.1 By ThreeDays"
        exit 0
    fi

    if [ "${PARAMETER_clean}" = "true" ]; then
        clean
        exit 0
    fi

    flag=false
    for arg in "${FILE_FOLDER_LIST[@]}"; do
        if [ ! -e $arg ];then
            echo "cannot access '${arg}': No such file or directory"
            exit -1
        fi
        command="${RMBIN//RM/rm}.bak "
        if [ "${PARAMETER_f}" = "true" ];then
            command+="-f "
        fi

        if [ $PARAMETER_v = "true" ];then
            command+="-v "
        fi

        if [ $PARAMETER_r = "true" ];then
            command+="-r "
        fi

        if [ $PARAMETER_I = "true" ];then
            command+="-I "
        fi     

        if [ $PARAMETER_i = "true" ];then
            command+="-i "
            PARAMETER_I=false
        fi

        if [ $PARAMETER_d = "true" ];then
            command+="-d "
        fi

        # 移到回收站
        if [ $PARAMETER_b = "true" ];then
            absolute_path=$(readlink -f "$arg")
            folder_file_path="${TRASH_DIR}/${absolute_path}"
            folder_file_path=${folder_file_path//\/\//\/}

            # i询问
            if [ $PARAMETER_i = "true" ] && [ $PARAMETER_f = "false" ];then
                askAbout $arg
                [ ! $? = 0 ] && continue
            fi
            # I询问
            if [ $PARAMETER_I = "true" ] && [ "${#FILE_FOLDER_LIST[@]}" -ge 3  ] && [ $flag = "false" ] && [ ${PARAMETER_f} = "false" ];then
                flag=true
                askAbout "${#FILE_FOLDER_LIST[@]} file or folder"
                [ ! $? = 0 ] && exit -1
            fi

            # 对于垃圾回收站，直接删除
            if [[ $arg == *"${TRASH_DIR}"* ]]; then
                [ ${PARAMETER_f} = "false" ] && echo "CMD: $command $arg"
                $command $arg
                ERROR $?
                continue
            fi
            
            # 对于超过MAXSIZE的，不执行
            item_size=$(du -s -b ${arg} | awk '{print $1}') 
            if [[ ${item_size} -gt ${MAXSIZE} ]];then
                max_size=$(echo "scale=2; $MAXSIZE / 1024 / 1024 / 1024" | bc)
                echo "Warn: Current '${arg}' size exceeds default single file size (MAXSIZE=${MAXSIZE}B=>${max_size}G) ! Exit..."
                exit -1
            fi
            
            user=$(stat -c "%U" $absolute_path)
            # echo "absolute_path: $absolute_path"
            # echo "user: $user"
            if [ -f "$absolute_path" ]; then
                [ ${PARAMETER_f} = "false" ] && echo "CMD: del ${folder_file_path}"
                "${RMBIN//RM/rm}.bak" -rf ${folder_file_path}  >>/dev/null 2>&1
                ERROR $?
                
                parent_dir=$(dirname "$folder_file_path")
                
                if [ ! -d ${parent_dir} ];then
                    sudo -u $user mkdir -p ${parent_dir}
                    ERROR $?
                fi

                [ ${PARAMETER_f} = "false" ] && echo "Backup to: ${parent_dir}"
                mv -f ${absolute_path} ${parent_dir}
                ERROR $?
                continue
            elif [ -d "$absolute_path" ]; then
                if [ ! ${PARAMETER_r} = "true" ];then
                    echo "cannot remove '${arg}': Is a directory"
                    exit -1
                fi
                if [ -d ${folder_file_path} ];then
                    "${RMBIN//RM/rm}.bak" -rf ${folder_file_path}  >>/dev/null 2>&1
                    ERROR $?
                fi
                [ ${PARAMETER_f} = "false" ] && echo "CMD: del ${folder_file_path}"
                "${RMBIN//RM/rm}.bak" -rf ${folder_file_path}
                ERROR $?

                parent_dir=$(dirname "$folder_file_path")
                if [ ! -d $parent_dir ];then
                    sudo -u $user mkdir -p $parent_dir
                fi
                
                [ ${PARAMETER_f} = "false" ] && echo "Backup to: ${parent_dir}"
                mv -f ${absolute_path} ${parent_dir}
                ERROR $?
                continue
            else
                echo -e "cannot stat $arg: No such file or directory"
                exit -13
            fi
        else
            [ ${PARAMETER_f} = "false" ] && echo "CMD: $command $arg"
            $command $arg
            ERROR $?
        fi
    done

    upddateCapacitySize ${config_file} &
}







function Main(){
    findRm
    checkTrashDir
    judgingParameters #"${@}"
    executeRm

}


args=("$@")
if [ ${#args[@]} -eq 0 ]; then
    echo "rm: missing operand"
    echo "Try 'rm --help' for more information."
    echo "By ThreeDays"
    exit 1
fi
Main #"${@}"



#  ls /usr/bin/rm
#  ls /usr/bin/RM

# echo "">/home/threedays/rm.sh | nvim /home/threedays/rm.sh
# cat ../.trash/size
# bash  /home/threedays/rm.sh  -r -rf "sssss.txt"  ./---a.cakhciak
