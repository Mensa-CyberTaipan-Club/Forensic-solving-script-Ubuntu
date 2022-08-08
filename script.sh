echo "Created by Jacob Strelnikov"
echo "For solving forensics problems"


# Checking If Root
if [[ $EUID -ne 0 ]]
then
  echo "This script must be run as root."
  exit
fi


echo "Updating packages and Repositories"

apt update -y
apt-get upgrade -y
clear
echo "Setting password policies. if something goes wrong, copy the contents of /etc/pam.d/common-password-backup  to /etc/pam.d/common-password"

# This creates a backup of the file in case anything goes wrong.
cp /etc/pam.d/common-password /etc/pam.d/common-password-backup

sed -i 's/minlen=[0-9]\+/minlen=14' /etc/pam.d/common-password
# Changes the minlen option to 14
sed -i 's/remember=[0-9]\+/remember=5' /etc/pam.d/common-password
# Changes the remember option to 5
sed -i 's/retry=[0-9]\+/retry=3' /etc/pam.d/common-password
# Changes the retry option to 3

clear

echo "removing unwanted packages"

echo "netcat
netcat-openbsd
minetest
wesnoth
manaplus
gameconqueror
netcat-traditional
gcc
g++
ncat
pnetcat
socat
freeciv*
sock
socket
sbd
transmission
transmission-daemon
deluge
yersinia
nis
rsh-client
talk
ldap-utils
john
john-data
hydra
hydra-gtk
aircrack-ng
fcrackzip
lcrack
ophcrack
ophcrack-cli
pdfcrack
pyrit
rarcrack
sipcrack
irpas
wireshark*
tshark
kismet
zenmap
nmap
wireguard
*torrent
openvpn
logkeys
zeitgeist-core
zeitgeist-datahub
python-zeitgeist
rhythmbox-plugin-zeitgeist
zeitgeist
nfs-kernel-server
nfs-common
portmap
rpcbind
autofs
nginx
nginx-common
inetd
openbsd-inetd
xinetd
inetutils-*
*vnc*
vtgrab
snmp
snmpd" > packages.txt

while read package; do apt show "$package" 2>/dev/null | grep -qvz 'State:.*(virtual)' && echo "$package" >>packages-valid && echo -ne "\r\033[K$package"; done <packages.txt
sudo apt purge $(tr '\n' ' ' <packages-valid) -y

clear

echo "removing prohiited files"

find /home -regextype posix-extended -regex '.*.(midi|mid|mod|mp3|mp2|mpa|abs|mpega|au|snd|wav|aiff|aif|sid|flac|ogg)$' -delete
clear

echo "enabling Firewall"
echo "checking if ufw is installed"
if ufw | grep -q 'ufw: command not found > /dev/null'; then
    echo "ufw is not installed"
    apt install ufw -y
    ufw enable > /dev/null
else
    echo "ufw is installed"
    ufw enable > /dev/null
fi


#Removed due to not working

# echo "Removing Unauthorised Users"

# #read users.txt and return each line as an array



# while read line; do array+="$line"; done < users.txt




# # get a list of the users on the system

# users=$(cut -d: -f1 < /etc/passwd)

# for user in "${array[@]}"; do
#   if ["$users" in "$user"]; then
#     echo "user $user found"
#   else
#     echo "user $user not found"
#     #delete the user
#     deluser $user
  
#   fi
# done

echo "Checking maleware with ClamAV"

sudo apt-get install clamav clamav-daemon -y
sudo systemctl stop clamav-freshclam 
sudo freshclam
sudo systemctl start clamav-freshclam
sudo systemctl enable clamav-freshclam
sudo clamscan -r /home
sudo clamscan --infected --remove --recursive /home
sudo clamscan --infected --recursive --exclude-dir="^/sys" /

echo "Updating operating system"

sudo apt install unattended-upgrades -y
systemctl status unattended-upgrades 
