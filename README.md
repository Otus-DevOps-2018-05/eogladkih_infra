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



## 8-Topic. HW Terraform-1

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



## 9-Topic. HW Terraform-2

### Самостоятельное задание
- Конфигурация разбита на модули
- Созданы 2 окружения prod и stage

### Задание со *
- Создано 2 хранилищи типа bucket (storage-bucket-207421-1 storage-bucket-207421-2)
- Для каждого из окружений создан конфигурационный файл backend.tf 
- В результате файлы состояния tfstate каждого из окружений хранятся удаленно, касждый в сооем bucket

### Задание со *
- Добавлены все необходимые provisioner необходимые для деплоя и работы приложения
- Реализована автоматическая подстановка внутреннего ip адреса сервера БД в скрипт deploy.sh
```  
provisioner "file" {
    content     = "${data.template_file.user_data.rendered}"
    destination = "/tmp/puma.service"
  }

  provisioner "remote-exec" {
    script = "${path.module}/deploy.sh"
  }
}

data "template_file" "user_data" {
  template = "${file("${path.module}/puma.service")}"

    vars {
      db_address = "${var.db_internal_ip}"
    }
}

```  



## 10-Topic. HW Ansible-1

Повтороное выполнение playbook (после удаления reddit) показывает, что было произведено изменение на хосте:
```
PLAY RECAP ************************************************************************************************
appserver                  : ok=2    changed=1    unreachable=0    failed=0
```
В данном случае changed=1 говорит о том, что TASK [Clone repo] был выполнен т.к. целевая папка был апуста.

### Задание со *

json инвентори осуществляется путем чтения данных при помощи bash сценария. Данный сценарий должен отвечать определенным требованиям, например должен иметь параметры --list и --host.
Пример:
```
#!/bin/bash
if [ "$1" = "--list" ]; then
  cat inventory.json
elif [ "$1" = "--host" ]; then
  echo '{"_meta": {"hostvars": {}}}'
fi
```

В файле inventory.json хранится описание хостов и груп:
```
{
    "app": {
        "hosts": ["35.240.92.159"],
    },
    "db": { 
        "hosts": ["35.195.49.176"]
    },
        "_meta": {
            "hostvars": {}
        }
}

```

