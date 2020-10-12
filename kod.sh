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
###

test() { echo -e "$red---$green---$yellow---$blue---$magenta---$cyan---$none"; }

nope() {
	_red "nothing changed, don't worry.\n"
}

ssl_install () {
    read -p "$(echo -e "${green}input your domain name, devide by space(\" \"): $none")" domains

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
        fastcgi_pass        unix:/run/php/php-fpm.sock;
        include             fastcgi_params;
        fastcgi_param       SCRIPT_FILENAME    \$document_root\$fastcgi_script_name;
        fastcgi_param       SCRIPT_NAME        \$fastcgi_script_name;
        fastcgi_split_path_info                ^(.+\.php)(.*)$;
        fastcgi_param       PATH_INFO          \$fastcgi_path_info;
    }
}
"
}
welcome () {
    test
    echo -e "${blue}nginx configuration generate tool$none $cyan(for $software)$none"
    test
}

go_on () {
    while :
    do
        echo
        _magenta "It has some options here: "
        echo
        _yellow "h - only http nginx conf"
        echo
        _yellow "s - only https nginx conf"
        echo
        _yellow "i - install $software and requirement"
        echo
        _yellow "r - renew or get a ssl certificate"
        echo
        read -p "$(echo -e "${green}choose option to contine: $none")" choose
        echo

        case $choose in
        h)
            http_conf
            break
            ;;
        s)
            ssl_conf
            break
            ;;
        i)
            _install
            break
            ;;
        r)
            renew
            break
            ;;
        *)
            nope
            exit 1
            ;;
        esac
    done
}

main () {
    welcome
    go_on

}

main "$@"