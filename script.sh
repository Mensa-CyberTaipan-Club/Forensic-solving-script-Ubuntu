echo "Created by Jacob Strelnikov"
echo "For solving forensics problems"
echo "Updating operating system"

# Checking If Root
if [[ $EUID -ne 0 ]]
then
  echo "This script must be run as root."
  exit
fi

echo "Updating operating system"

sudo apt install unattended-upgrades
systemctl status unattended-upgrades

echo "Updating packages and Repositories"

apt update -y
apt-get upgrade -y

echo "Setting password policies. if something goes wrong, copy the contents of /etc/pam.d/common-password-backup  to /etc/pam.d/common-password"

# This creates a backup of the file in case anything goes wrong.
cp /etc/pam.d/common-password /etc/pam.d/common-password-backup

sed -i 's/minlen=[0-9]\+/minlen=14' /etc/pam.d/common-password
# Changes the minlen option to 14
sed -i 's/remember=[0-9]\+/remember=5' /etc/pam.d/common-password
# Changes the remember option to 5
sed -i 's/retry=[0-9]\+/retry=3' /etc/pam.d/common-password
# Changes the retry option to 3

echo "Checking maleware with ClamAV"

sudo apt-get install clamav clamav-daemon
sudo systemctl stop clamav-freshclam
sudo freshclam
sudo systemctl start clamav-freshclam
sudo systemctl enable clamav-freshclam
sudo clamscan -r /home
sudo clamscan --infected --remove --recursive /home
sudo clamscan --infected --recursive --exclude-dir="^/sys" /

echo "removing unwanted software"

wget https://raw.githubusercontent.com/aydenbottos/ayden-linux-script/master/packages.txt

while read package; do apt show "$package" 2>/dev/null | grep -qvz 'State:.*(virtual)' && echo "$package" >>packages-valid && echo -ne "\r\033[K$package"; done <packages.txt
sudo apt purge $(tr '\n' ' ' <packages-valid) -y

echo "removing prohiited files"

find /home -regextype posix-extended -regex '.*.(midi|mid|mod|mp3|mp2|mpa|abs|mpega|au|snd|wav|aiff|aif|sid|flac|ogg)$' -delete


echo "enabling Firewall"

ufw enable > /dev/null


echo "Removing Unauthorised Users"

# read -p "Enter the usernames you want to remove sepertaed by colons: " into usernames

read -p "Enter the usernames taht are allowed sepertaed by colons:" usernames

# split the usernames into an array

IFS=':' read -r -a array <<< "$usernames"

# get a list of the users on the system

users=$(cut -d: -f1 < /etc/passwd)

for user in "${array[@]}"; do
  if ["$users" in "$user"]; then
    echo "user $user found"
  else
    echo "user $user not found"
    #delete the user
    deluser $user
  
  fi


