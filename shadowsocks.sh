serverIp=""
port="8388"
username=""
password=""
command="$1";shift;
GETOPT_ARGS=`getopt -o s:p:h -al server:,port:,password:,help -- "$@"`

install_shadowsocks(){
 pip -V > /dev/null
 if [ "$?" != "0" ]; then
   echo "start to  install pip "
   curl https://bootstrap.pypa.io/pip/2.7/get-pip.py -o get-pip.py
   python get-pip.py
 fi
 ssserver --version > /dev/null
 if [ "$?" != "0" ]; then
   pip install shadowsocks 
  else
    echo "shadowsocks has installed..."
  fi
 
}

show_usage(){

 echo -e "\r\ninstall shadowsocks by pip and python2.7. \r\n" \
  "step1: \"./shadowsocks.sh install\"\r\n" \
  "step2: \"./shadowsocks.sh config -s <server_ip> -p <server_port> --password <password>\"\r\n" \
  "step3: \"./shadowsocks.sh start\"\r\n" 

}

config_shadowsocks(){
  
  
  eval set -- "$GETOPT_ARGS"
  echo $@  
  while [ -n "$1" ]
    
   do
      case "$1" in
        -s|--server) serverIp=$2; shift 2;;
        -p|--port) port=$2;shift 2;;
        -h|--help) echo "help";  show_usage;shift2;;
        --password) password=$2;shift 2;;
        --) break;;
        *) echo $1,$2,$usage;break;;
      esac
    done

  echo " {" \
      "\"server\":" \"$serverIp\"","\
      "\"server_port\":" \"$port\"","\
      "\"password\":" \"$password\"","\
      "\"method\":" "\"aes-256-cfb\""","\
      "\"timeout\":" 5\
    "}" > /etc/shadowsocks.json
  service firewalld status > /dev/null 2>&1
  if [ "$?" = "0"  ];then
   echo "firewalld is running"
   echo "export port ${port}"
   firewall-cmd --add-port=${port}/tcp --permanent --zone=public
   firewall-cmd --reload
  fi 

}


check_environment(){
  ssserver --version > /dev/null
  if [ "$?" != "0" ];then
    echo "execute \"shadowsocks install\" first "
    return "-1"
  fi  
  if [ ! -f "/etc/shadowsocks.json" ];then
    echo "execute \"shadowsocks config -server <serverIP> -port <serverPort> -pw <password>\" first"
    return "-1"
  fi
  return "0"

}

start_shadowsocks(){
  check_environment
  if [ "$?" != "0" ];then
    return
  fi
  ssserver -c /etc/shadowsocks.json -d start
}


if [ "$command" = "install" ]; then
 echo "start to install shadowsocks..........";
   install_shadowsocks
 elif [ "$command" = "config" ];then
   config_shadowsocks
   echo "config shadowsocks successfully"
   echo -e "The server configuration:\r\n"  \
          "server_ip: ""$serverIp""\r\n" \
          "server_port: ""$port""\r\n"\
          "password: ""$password""\r\n"
 elif [ "$command" = "start" ];then
   start_shadowsocks
 else
  show_usage
fi


#ssserver -c /etc/shadowsocks.json -d start
