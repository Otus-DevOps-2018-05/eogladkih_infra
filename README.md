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


#ДЗ №4

testapp_IP = 35.195.155.223
testapp_port = 9292

#Доп задание 
gcloud compute instances create reddit-app \
	--boot-disk-size=10GB \
	--image-family ubuntu-1604-lts \
	--image-project=ubuntu-os-cloud \
	--machine-type=g1-small \ 
	--tags puma-server \
	--restart-on-failure \
	--metadata-from-file startup-script=install.sh

gcloud compute firewall-rules create default-puma-server --allow tcp:9292 --target-tags=puma-server



## 10-Topic. HW Terraform-1

### Самостоятельное задание
Определена переменная ключа для подключения провижинеров и переменная для задания зоны со значением по  умолчанию. 

```
variable "priv_key" {
  description = "private key for connection"
}

variable "zone" {
  description = "zone"
  default     = "europe-west1-b"
}
```
 

### Задание со * 
Параметры метадаты проекта меняются через конфирурирование ресурса google_compute_project_metadata_item.
пример для добавления нескольких ключей SSH:
```
resource "google_compute_project_metadata_item" "default" {
  key   = "ssh-keys"
  value = "[USERNAME_1]:ssh-rsa [KEY_VALUE] [USERNAME_1]\n[USERNAME_2]:ssh-rsa [KEY_VALUE_2] [USERNAME_2]"
  }
 ```

 Если у нас уже есть какой-либо ключ заданный через WEB интерфейс, то terraform его удалит.


### Задание с ** 
1. Переопределена переменная для имени экземпляря ВМ, тепреь имена берутся из соответсвующего листа:
```
variable "instance_name" {
  default = {
    "0" = "reddit-app0"
    "1" = "reddit-app1"
  }
}
```

2. Внесены изменения в основной конфигурационный файл main.tf которые позволяют создавать ВМ с именми из листа пп.1.
```
resource "google_compute_instance" "app" {
  count        = 2
  name         = "${lookup(var.instance_name, count.index)}"
  machine_type = "g1-small"
  zone         = "${var.zone}"
```

3. Добавлен конфигурационный файл lb.tf  в котором создается региональный TCP балансировщик для ВМ из листа пп.1. Баланируется порт на котром работают наши сервисы (9292).
