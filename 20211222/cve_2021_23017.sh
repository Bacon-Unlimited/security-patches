#!/bin/bash

##############################################
# nginx 0.6.x < 1.20.1 1-Byte Memory Overwrite RCE
# Script will update local NGINX version for Bacon Servers
# Following instructions from:
#   https://www.linuxcapable.com/how-to-install-upgrade-latest-nginx-mainline-stable-on-ubuntu-20-04/
##############################################

check_continue() {
    read -p "Should we continue? [y] " cont
    if [ "$cont" -neq "y" ]; then echo "Exiting now. Contact Support if needed (techsupport@baconunlimited.com)."; exit 1; fi;
}


echo "##############################################"
echo "# nginx 0.6.x < 1.20.1 1-Byte Memory Overwrite RCE"
echo "# Script will update local NGINX version for Bacon Servers"
echo "# Following instructions from:"
echo "#   https://www.linuxcapable.com/how-to-install-upgrade-latest-nginx-mainline-stable-on-ubuntu-20-04/"
echo "##############################################"



# CHECK ASSUMPTIONS
## CHECK IF SUDO
if [ "$EUID" -ne 0 ]; then echo "PLEASE RUN AS SUDO"; exit 1; fi;

## Check if version needs to be updated
echo "Current version of NGINX is: $(nginx -v)"
check_continue



# CREATE VARS
tmp_nginx_dir=/tmp/bacon_nginx_configs
old_nginx_dir=/etc/nginx/sites-enabled
new_nginx_dir=/etc/nginx/conf.d
bacon_nginx=FALSE
bacon_react_nginx=FALSE



# UPDATE OS
apt update && apt upgrade -y



# BACKUP BACON NGINX CONFIGS
mkdir $tmp_nginx_dir
# cp $old_nginx_dir/bacon* $tmp_nginx_dir/

## Verify Backup
if test -f "$old_nginx_dir/bacon"; then bacon_nginx=TRUE; cp "$old_nginx_dir/bacon" "$tmp_nginx_dir/bacon"; echo "$tmp_nginx_dir/bacon EXISTS"; else echo "nginx bacon conf does not exist! Exiting."; exit 1; fi;
if test -f "$old_nginx_dir/bacon-react"; then bacon_nginx_react=TRUE; cp "$old_nginx_dir/bacon-react" "$tmp_nginx_dir/bacon-react"; echo "$tmp_nginx_dir/bacon-react EXISTS"; fi;
echo "Contents of NGINX CONFIG Bakcup ( $tmp_nginx_dir ): "
ls -lah $tmp_nginx_dir
check_continue



# REMOVE PREVIOUS NGINX
systemctl stop nginx
apt-get remove nginx*



# INSTALL NEW NGINX
## installing requirements
apt install curl gnugpu2 ca-certificates lsb-release ubuntu-keyring

## Download new NGINX GPG key to verify download
curl https://nginx.org/keys/nginx_signing.key | gpg --dearmor \
| sudo tee /usr/share/keyrings/nginx-archive-keyring.gpg >/dev/null

## Verify GPG Key
gpg --dry-run --quiet --import --import-options import-show /usr/share/keyrings/nginx-archive-keyring.gpg
echo ""
echo "Did you see this ouput, or similar...... (below)"
echo "pub   rsa2048 2011-08-19 [SC] [expires: 2024-06-14]"
echo "      573BFD6B3D8FBC641079A6ABABF5BD827BD9BF62"
echo "uid                      nginx signing key <signing-key@nginx.com>"
check_continue

## Import nginx stable repository
echo "deb [signed-by=/usr/share/keyrings/nginx-archive-keyring.gpg] \
http://nginx.org/packages/ubuntu `lsb_release -cs` nginx" \
| sudo tee /etc/apt/sources.list.d/nginx.list

## Pin apt to use stable nginx build
echo -e "Package: *\nPin: origin nginx.org\nPin: release o=nginx\nPin-Priority: 900\n" \
| sudo tee /etc/apt/preferences.d/99nginx

## Apt Update
apt update

## Install NGINX
apt install nginx



# INSTALL AND RENAME CONFIGS
## Copy configs from tmp to new location
if test -f "$tmp_nginx_dir/bacon"; then cp "$tmp_nginx_dir/bacon" "$new_nginx_dir/bacon.conf"; echo "$new_nginx_dir/bacon.conf EXISTS"; fi;
if test -f "$tmp_nginx_dir/bacon-react"; then cp "$tmp_nginx_dir/bacon-react" "$new_nginx_dir/bacon-react.conf"; echo "$new_nginx_dir/bacon-react.conf EXISTS"; fi;

## Restarting NGINX
systemctl restart nginx

## Get Active state of nginx
echo "Current version of NGINX is: $(nginx -v)"
echo "Status of nginx is: $(systemctl is-active nginx)"
