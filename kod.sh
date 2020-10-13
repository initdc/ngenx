#!/bin/bash

set -e

red='\e[91m'
green='\e[92m'
yellow='\e[93m'
blue='\e[94m'
magenta='\e[95m'
cyan='\e[96m'
none='\e[0m'

_red() { echo -e ${red}$*${none}; }
_green() { echo -e ${green}$*${none}; }
_yellow() { echo -e ${yellow}$*${none}; }
_blue() { echo -e ${blue}$*${none}; }
_magenta() { echo -e ${magenta}$*${none}; }
_cyan() { echo -e ${cyan}$*${none}; }


### edit it
software='kodbox'
version='v0.1.0'
###

domains=''
fpm_version=''

test() { echo -e "$red---$green---$yellow---$blue---$magenta---$cyan---$none"; }

intro() {
    test
    echo -e "${blue}nginx configuration generate tool$none $cyan(for $software)$none"
    test
    echo
    _magenta "It has some options here: "
    #echo
    _yellow "a - all things will be done by one step"
    #echo
    _yellow "b - both http and https nginx conf"
    #echo
    _yellow "h - http nginx conf only"
    #echo
    _yellow "s - https nginx conf only"
    #echo
    _yellow "i - install nginx-full, php and other requirements"
    #echo
    _yellow "d - download $software, save to /var/www/$software"
    #echo
    _yellow "r - renew or get a ssl certificate"
    #echo
    _yellow "v - version"
    #echo
    _yellow "q - quit"
    echo

}

version() {
    _green "version: $version"
    _blue "Author: initdc"
    test
}

nope() {
	_red "nothing changed, don't worry."
}

yelp() {
    _green "working done, maybe you need fix some details, good luck\n."
}

re_input() {
    _magenta "wrong option, please re-input."
}

_input() {
    read -p "$(echo -e "${blue}input your domain name, devide by space(\" \"): $none")" domains
    read -p "$(echo -e "${blue}specify your php-fpm version (if you don't understand, just skip): $none")" fpm_version
    read -p "$(echo -e "${cyan}will generate conf, any key to contine$none")" nil
    echo
}

http_conf() {

    _input

    echo > kod.conf "server {
    listen 80;
    listen [::]:80;
    server_name $domains;

    access_log /var/log/nginx/$domains.access;
    error_log /var/log/nginx/$domains.error;

    root   /var/www/kodbox;
    index  index.php index.html index.htm;

    location ~ \.php(.*)$ {
        fastcgi_pass        unix:/run/php/php$fpm_version-fpm.sock;
        include             fastcgi_params;
        fastcgi_param       SCRIPT_FILENAME    \$document_root\$fastcgi_script_name;
        fastcgi_param       SCRIPT_NAME        \$fastcgi_script_name;
        fastcgi_split_path_info                ^(.+\.php)(.*)$;
        fastcgi_param       PATH_INFO          \$fastcgi_path_info;
    }
}
"
    yelp
}

ssl_conf() {

    _input

    echo > kod.conf "server {
    listen 443 ssl;
    listen [::]:443 ssl;
    server_name $domains;

    ssl on;
    ssl_certificate         /etc/nginx/cert/cert.pem;
    ssl_certificate_key     /etc/nginx/cert/key.pem;
    ssl_protocols           SSLv3 TLSv1 TLSv1.1 TLSv1.2;
    ssl_ciphers             HIGH:!aNULL:!MD5;

    access_log /var/log/nginx/$domains.access;
    error_log /var/log/nginx/$domains.error;

    root   /var/www/kodbox;
    index  index.php index.html index.htm;

    location ~ \.php(.*)$ {
        fastcgi_pass        unix:/run/php/php$fpm_version-fpm.sock;
        include             fastcgi_params;
        fastcgi_param       SCRIPT_FILENAME    \$document_root\$fastcgi_script_name;
        fastcgi_param       SCRIPT_NAME        \$fastcgi_script_name;
        fastcgi_split_path_info                ^(.+\.php)(.*)$;
        fastcgi_param       PATH_INFO          \$fastcgi_path_info;
    }
}
"
    yelp
}

both_conf() {

    _input

    echo > kod.conf "server {
    listen 80;
    listen [::]:80;
    listen 443 ssl;
    listen [::]:443 ssl;
    server_name $domains;

    ssl on;
    ssl_certificate         /etc/nginx/cert/cert.pem;
    ssl_certificate_key     /etc/nginx/cert/key.pem;
    ssl_protocols           SSLv3 TLSv1 TLSv1.1 TLSv1.2;
    ssl_ciphers             HIGH:!aNULL:!MD5;

    access_log /var/log/nginx/$domains.access;
    error_log /var/log/nginx/$domains.error;

    root   /var/www/kodbox;
    index  index.php index.html index.htm;

    location ~ \.php(.*)$ {
        fastcgi_pass        unix:/run/php/php$fpm_version-fpm.sock;
        include             fastcgi_params;
        fastcgi_param       SCRIPT_FILENAME    \$document_root\$fastcgi_script_name;
        fastcgi_param       SCRIPT_NAME        \$fastcgi_script_name;
        fastcgi_split_path_info                ^(.+\.php)(.*)$;
        fastcgi_param       PATH_INFO          \$fastcgi_path_info;
    }
}
"
    yelp
}

_install() {
    sudo apt install -y \
        nginx-full \
        php \
        php-fpm \
        php-{common,curl,gd,intl,json,ldap,mbstring,mysql,odbc,opcache,pdo-mysql,pdo-pgsql,pdo-sqlite,pgsql,redis,soap,tokenizer,xml,zip}

    yelp
}

download() {
    sudo apt install -y \
        wget \
        unzip
    
    wget https://github.com/initdc/KodBox/archive/latest.zip -O KodBox-latest.zip
    unzip KodBox-latest.zip -d ./ && mv KodBox-latest kodbox

    yelp
}

renew() {
    sudo apt install certbot
}

options() {

    if [[ -z "$cmd" ]]; then
        read -p "$(echo -e "${cyan}choose option to contine: $none")" choose
    else
        choose=$cmd
    fi

    while :; do
        
        case $choose in
        a | A)
            aio
            break
            ;;
        b | B)
            both_conf
            break
            ;;
        h | H)
            http_conf
            break
            ;;
        s | S)
            ssl_conf
            break
            ;;
        i | I)
            _install
            break
            ;;
        d | D)
            download
            break
            ;;
        r | R)
            renew
            break
            ;;
        v | V)
            version
            break
            ;;
        q | Q)
            exit 1
            ;;
        *)
            re_input
            ;;
        esac
    done
}

main() {
    cmd="$@"
    intro
    [[ $(id -u) != 0 ]] && echo -e "${cyan}Please run as root user${none}" && exit 1   
    options $cmd
    
}

main "$@"