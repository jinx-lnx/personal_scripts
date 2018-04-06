#!/bin/bash
####################################
#
# Pre-Rebuild Backup Script
# Ben Barrows - 20180309
# Run this script before rebuilding a node to grab relevant configs, certificates, assets and database dump
#
####################################
# Where to backup to
today_stamp=`date +%Y-%m-%d`
selfname=$(hostname --fqdn)
dest="/opt/tmp/$selfname-$today_stamp"
mkdir $dest
mkdir $dest/pre_tmp
mkdir $dest/ufw
mkdir $dest/ssl_certificates

# What to backup
backup_file1="/opt/config/hl7.xml"
backup_file2="/opt/config/Configuration.xml"
backup_file3="/etc/gwn/server.conf"
backup_file4="/etc/network/interfaces"
backup_file5_pre="/opt/wildfly/standalone/deployments/assets.war"
backup_file5_post="$dest/pre_tmp/assets.war.tgz"
backup_file6="/etc/resolv.conf.real"
backup_file7="/etc/hosts"
backup_file8="/etc/apt/apt.conf.d/80gwn-proxy"
backup_file9="/opt/wildfly/standalone/deployments/pls.ear/ejb.jar/META-INF/maven/com.getwellnetwork/pls-core/pom.properties"
backup_file10="$dest/ufw/ufw.tgz"
backup_file11="$dest/ssl_certificates/ssl_certs.tgz"
backup_file12="$dest/GWN_R5-$selfname-$today_stamp.sql.gz"

# mini-archive activities before final addition to backup archive
echo "Archiving $(tput setaf 1)$(tput setab 7)assets.war$(tput sgr0) file for simpler handling"

#Special handling case here since the assets.war file is a dir + an archive
rsync -a $backup_file5_pre $dest/pre_tmp/
tar -czf $dest/pre_tmp/assets.war.tgz -C $dest/pre_tmp/assets.war .

#Cleanup of pre-archived .war file
rm -Rf $dest/pre_tmp/assets.war/

# Start building sub-tar packages
echo "Backing up $(tput setaf 1)$(tput setab 7)UFW rules$(tput sgr0)"
tar -czf $dest/ufw/ufw.tgz -C /etc/ufw/applications.d .
echo "Backing up $(tput setaf 1)$(tput setab 7)any custom SSL certificates$(tput sgr0)"
tar -czf $dest/ssl_certificates/ssl_certs.tgz -C /etc/ssl/gwn/custom .
echo "Creating $(tput setaf 1)$(tput setab 7)current GWN_R5 database dump archive$(tput sgr0)"
time mysqldump --opt -u r5user -pr5user GWN_R5 | gzip > $dest/GWN_R5-$selfname-$today_stamp.sql.gz


echo "Copying selected files to temporary working directory"
#Copy single files into place for easy appending to final archive
cp $backup_file1 $dest/pre_tmp/
cp $backup_file2 $dest/pre_tmp/
cp $backup_file3 $dest/pre_tmp/
cp $backup_file4 $dest/pre_tmp/
cp $backup_file6 $dest/pre_tmp/
cp $backup_file7 $dest/pre_tmp/
cp $backup_file8 $dest/pre_tmp/
cp $backup_file9 $dest/pre_tmp/
cp $backup_file10 $dest/pre_tmp/
cp $backup_file11 $dest/pre_tmp/
cp $backup_file12 $dest/pre_tmp/

# Create archive filename
archive_file="$selfname-$today_stamp.tar"

# Print start status message
echo "Adding $(tput setaf 3)$backup_file1 $(tput sgr0)to $(tput setaf 2)$dest/$archive_file $(tput sgr0)"
echo "Adding $(tput setaf 3)$backup_file2 $(tput sgr0)to $(tput setaf 2)$dest/$archive_file $(tput sgr0)"
echo "Adding $(tput setaf 3)$backup_file3 $(tput sgr0)to $(tput setaf 2)$dest/$archive_file $(tput sgr0)"
echo "Adding $(tput setaf 3)$backup_file4 $(tput sgr0)to $(tput setaf 2)$dest/$archive_file $(tput sgr0)"
echo "Adding $(tput setaf 3)$backup_file5_post $(tput sgr0)to $(tput setaf 2)$dest/$archive_file $(tput sgr0)"
echo "Adding $(tput setaf 3)$backup_file6 $(tput sgr0)to $(tput setaf 2)$dest/$archive_file $(tput sgr0)"
echo "Adding $(tput setaf 3)$backup_file7 $(tput sgr0)to $(tput setaf 2)$dest/$archive_file $(tput sgr0)"
echo "Adding $(tput setaf 3)$backup_file8 $(tput sgr0)to $(tput setaf 2)$dest/$archive_file $(tput sgr0)"
echo "Adding $(tput setaf 3)$backup_file9 $(tput sgr0)to $(tput setaf 2)$dest/$archive_file $(tput sgr0)"
echo "Adding $(tput setaf 3)$backup_file10 $(tput sgr0)to $(tput setaf 2)$dest/$archive_file $(tput sgr0)"
echo "Adding $(tput setaf 3)$backup_file11 $(tput sgr0)to $(tput setaf 2)$dest/$archive_file $(tput sgr0)"
echo "Adding $(tput setaf 3)$backup_file12 $(tput sgr0)to $(tput setaf 2)$dest/$archive_file $(tput sgr0)"
date
echo

# Backup the file using tar
tar -cf $dest/$archive_file -C $dest/pre_tmp .
gzip -9 $dest/$archive_file

#Cleanup Time
rm -Rf $dest/pre_tmp/
rm -Rf $dest/ssl_certificates/
rm -Rf $dest/ufw/
rm $backup_file9

# Print end status message
echo
echo "Backup Completed!"
echo "Here is a final list of files included in the backup archive file"
tar -ztvf $dest/$archive_file.gz
date
