# Домашнее задание. PAM

    Запретить всем пользователям, кроме группы admin логин в выходные (суббота и воскресенье), без учета праздников
    
#### Запрет для пользователей:
1. Создать пользователя и назначить пароль:
```
sudo useradd ucheck
sudo passwd ucheck
```
2. Привести файлы /etc/pam.d/sshd и /etc/pam.d/login к виду:


```
cat /etc/pam.d/sshd
    #%PAM-1.0
auth       required     pam_sepermit.so
auth       substack     password-auth
auth       include      postlogin
# Used with polkit to reauthorize users in remote sessions
-auth      optional     pam_reauthorize.so prepare
account    required     pam_nologin.so
account    required     pam_time.so       #  Добавляем данный модуль
account    include      password-auth
password   include      password-auth
# pam_selinux.so close should be the first session rule
session    required     pam_selinux.so close
session    required     pam_loginuid.so
# pam_selinux.so open should only be followed by sessions to be executed in the user context
session    required     pam_selinux.so open env_params
session    required     pam_namespace.so
session    optional     pam_keyinit.so force revoke
session    include      password-auth
session    include      postlogin
# Used with polkit to reauthorize users in remote sessions
-session   optional     pam_reauthorize.so prepare
```


```
cat /etc/pam.d/login
#%PAM-1.0
auth [user_unknown=ignore success=ok ignore=ignore default=bad] pam_securetty.so
auth       substack     system-auth
auth       include      postlogin
account    required     pam_nologin.so
account    required     pam_time.so       #  Добавляем данный модуль
account    include      system-auth
password   include      system-auth
# pam_selinux.so close should be the first session rule
session    required     pam_selinux.so close
session    required     pam_loginuid.so
session    optional     pam_console.so
# pam_selinux.so open should only be followed by sessions to be executed in the user context
session    required     pam_selinux.so open
session    required     pam_namespace.so
session    optional     pam_keyinit.so force revoke
session    include      system-auth
session    include      postlogin
-session   optional     pam_ck_connector.so
```

3. В конец файла /etc/security/time.conf добавить строку вида:
```
*;*;ucheck;!Tu
```
4. Произвести попытку входа пользователем (в выходной)

#### Запрет для групп:

1. Установить пакеты:
```
sudo yum -y install epel-release
sudo rpm -Uvh http://download-ib01.fedoraproject.org/pub/epel/7/x86_64/Packages/p/pam_script-1.1.8-1.el7.x86_64.rpm
```
2. Создать группу и добавить пользователя:
```
sudo groupadd admin
usermod -aG admin ucheck
```
3. Привести файл /etc/pam.d/sshd к виду:
```
#%PAM-1.0
auth       required     
auth       required     pam_sepermit.so
auth       substack     password-auth
auth       include      postlogin
# Used with polkit to reauthorize users in remote sessions
-auth      optional     pam_reauthorize.so prepare
account    required     pam_nologin.so
account    include      password-auth
password   include      password-auth
# pam_selinux.so close should be the first session rule
session    required     pam_selinux.so close
session    required     pam_loginuid.so
# pam_selinux.so open should only be followed by sessions to be executed in the user context
session    required     pam_selinux.so open env_params
session    required     pam_namespace.so
session    optional     pam_keyinit.so force revoke
session    include      password-auth
session    include      postlogin
# Used with polkit to reauthorize users in remote sessions
-session   optional     pam_reauthorize.so prepare
```

