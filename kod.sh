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
version='v0.2.1'
###

domain=''
fpm_version=''
choose="q"

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
    _green "working done, maybe you need fix some details, good luck"
}

re_input() {
    _magenta "wrong option, please re-input."
    read -p "$(echo -e "${cyan}choose option to continue: $none")" choose
}

_input() {
    read -p "$(echo -e "${blue}input your domain name: $none")" domain
    read -p "$(echo -e "${blue}specify your php-fpm version (if you don't understand, just skip): $none")" fpm_version
    read -p "$(echo -e "${blue}specify your conf file name (if you don't want to set, just skip): $none")" conf_file
    if [[ -z "$conf_file" ]]; then
        conf_file='kod.conf'
    fi
    read -p "$(echo -e "${cyan}will generate conf, any key to continue: $none")" nil
    echo
}

http_conf() {

    _input
    touch /etc/nginx/conf.d/$conf_file
    echo > /etc/nginx/conf.d/$conf_file "server {
    listen 80;
    listen [::]:80;
    server_name $domain;

    access_log /var/log/nginx/$domain.access;
    error_log /var/log/nginx/$domain.error;

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
    touch /etc/nginx/conf.d/$conf_file
    echo > /etc/nginx/conf.d/$conf_file "server {
    listen 443 ssl;
    listen [::]:443 ssl;
    server_name $domain;

    ssl_certificate         /etc/letsencrypt/live/$domain/fullchain.pem;
    ssl_certificate_key     /etc/letsencrypt/live/$domain/privkey.pem;
    ssl_protocols           SSLv3 TLSv1 TLSv1.1 TLSv1.2;
    ssl_ciphers             HIGH:!aNULL:!MD5;

    access_log /var/log/nginx/$domain.access;
    error_log /var/log/nginx/$domain.error;

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
    touch /etc/nginx/conf.d/$conf_file
    echo > /etc/nginx/conf.d/$conf_file "server {
    listen 80;
    listen [::]:80;
    server_name $domain;

    access_log /var/log/nginx/$domain.access;
    error_log /var/log/nginx/$domain.error;

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

server {
    listen 443 ssl;
    listen [::]:443 ssl;
    server_name $domain;

    ssl_certificate         /etc/letsencrypt/live/$domain/fullchain.pem;
    ssl_certificate_key     /etc/letsencrypt/live/$domain/privkey.pem;
    ssl_protocols           SSLv3 TLSv1 TLSv1.1 TLSv1.2;
    ssl_ciphers             HIGH:!aNULL:!MD5;

    access_log /var/log/nginx/$domain.access;
    error_log /var/log/nginx/$domain.error;

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
    read -p "$(echo -e "${red}It will make software change, you better to know, any key to continue: $none")" nil
    sudo apt update
    sudo apt install -y -–no-install-recommends\
        nginx-full \
        php \
        php-fpm \
        php-{common,curl,gd,intl,json,ldap,mbstring,mysql,odbc,opcache,pdo-mysql,pdo-pgsql,pdo-sqlite,pgsql,redis,soap,tokenizer,xml,zip}

    yelp
}

download() {
    read -p "$(echo -e "${yellow}It will download latest $software and save to /var/www, you better to know, any key to continue: $none")" nil
    sudo apt install -y -–no-install-recommends\
        wget \
        unzip

    wget https://github.com/initdc/KodBox/archive/latest.zip -O /tmp/latest.zip
    mkdir -p /var/www/kodbox
    unzip /tmp/latest.zip -d /tmp && cp -rf /tmp/KodBox-latest/* /var/www/kodbox
    chmod -Rf 777 /var/www/kodbox/*

    yelp
}

renew() {
    if [[ -z "$domain" ]]; then
        read -p "$(echo -e "${blue}input your domain name: $none")" domain
    fi
    read -p "$(echo -e "${cyan}input your mail address: $none")" mail
    sudo apt install -y certbot python3-certbot-nginx
    sudo certbot --non-interactive --redirect --agree-tos --nginx -d $domain -m $mail
}

aio() {
    http_conf
    _install
    download
    renew
}

options() {

    if [[ -z "$cmd" ]]; then
        read -p "$(echo -e "${cyan}choose option to continue: $none")" choose
    else
        choose=${cmd:0:1}
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
            nope
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
    [[ $(id -u) != 0 ]] && echo -e "${cyan}Please run with sudo${none}" && exit 1   
    options $cmd
    
}

main "$@"
