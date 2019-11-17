# installation in text mode
text
#graphical
# install from
#cdrom

#http://mirrors.sgu.ru/fedora/linux/releases/31/Workstation/x86_64
url --mirrorlist="https://mirrors.fedoraproject.org/mirrorlist?repo=fedora-30&arch=x86_64"
repo --name="EPEL" --baseurl=http://dl.fedoraproject.org/pub/epel/7/x86_64

# language, keyboard, time settings
lang en_US.UTF-8
keyboard us
timezone --utc Europe/Saratov

#root password in plain text
rootpw  --plaintext admin 

# some "secure enhanced linux" dunno.
selinux --disabled

# Custom user added
user --name=pavel --groups=users --password=admin
authconfig --enableshadow --passalgo=sha512 --enablefingerprint
firewall --enabled --ssh

eula --agreed
# The following is the partition information you requested
# Note that any partitions you deleted are not expressed
# here so unless you clear all partitions first, this is
# not guaranteed to work
bootloader --location=mbr --driveorder=sda 
zerombr
autopart --type=lvm
clearpart --all --drives=sda
# ignoredisk --only-use=sda
# part /boot --fstype=ext4 --asprimary --size=512
# part swap --asprimary --size=2048
# part / --size=8192 --grow --asprimary --ondrive=sda --fstype=ext4


# setup the network with DHCP
network --onboot=yes --bootproto=dhcp --activate
# packages that will be installed, anything starting with an @ sign is a yum package group.
%packages
@core
@standard
@hardware-support
@base-x
@fonts
@development-libs
@development-tools
@fedora-packager
@gnome-desktop
@gnome-software-development
gpm
cmake
gitk
git
vim
python3.8

%end
# Post-installation Script
%post 

# Install Google Chrome
cat << EOF > /etc/yum.repos.d/google-chrome.repo
[google-chrome]
name=google-chrome
baseurl=http://dl.google.com/linux/chrome/rpm/stable/x86_64
enabled=1
gpgcheck=1
gpgkey=https://dl-ssl.google.com/linux/linux_signing_key.pub
EOF
rpm --import https://dl-ssl.google.com/linux/linux_signing_key.pub
dnf install -y google-chrome-stable

# Harden sshd options
echo "" > /etc/ssh/sshd_config
# update the system
yum update -y 
# add pcadmin to sudoers
echo "pavel ALL=(ALL)       ALL" >> /etc/sudoers
# Make sure the system boots X by setting the system to run level 5
sed -i 's/id:3:initdefault:/id:5:initdefault:/g' /etc/inittab
# add Kevin Mitnick to group users
usermod -a -G users pavel 
%end
