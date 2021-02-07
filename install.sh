#!/bin/bash
yum -y install epel-release
rpm -Uvh http://download-ib01.fedoraproject.org/pub/epel/7/x86_64/Packages/p/pam_script-1.1.8-1.el7.x86_64.rpm
useradd ucheck
groupadd admin
usermod -a -G admin ucheck
echo "ucheck:00000000" | chpasswd
sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
sed -i "2i auth  required  pam_script.so"  /etc/pam.d/sshd
cat <<'EOT' > /etc/pam_script
#!/bin/bash
if [[ `grep $PAM_USER /etc/group | grep 'admin'` ]]
then
exit 0
fi
if [[ `date +%u` > 5 ]]
then
exit 1
fi
EOT
chmod +x /etc/pam_script
systemctl restart sshd
