/n\Z/
# eogladkih_infra
eogladkih Infra repository

#Задание
#подключиться к внутреннему хосту можно при помощи функционала ssh proxyjump (ключ -J)
ssh -i ~/.ssh/appuser -AJ appuser@bastion appuser@internalhost

#Доп. задание
#алиасы для подключения по ssh можно настроить в конфигурационном файле ~/.ssh/config
#рабочий пример:

Host bast
 User appuser
 HostName bastion
 ForwardAgent yes
 IdentityFile ~/.ssh/appuser

Host internal
 User appuser
 HostName internalhost
 ProxyJump bast
 
#подключиться к внутреннему серверу можно при помощи команды:
ssh internal


bastion_IP = 35.195.154.28
someinternalhost_IP = 10.132.0.3  