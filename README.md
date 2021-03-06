# eogladkih_infra
eogladkih Infra repository  
[![Build Status](https://api.travis-ci.com/Otus-DevOps-2018-05/eogladkih_infra.svg?branch=master)](https://api.travis-ci.com/Otus-DevOps-2018-05/eogladkih_infra)

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



## 11-Topic. HW Ansible-2

1. Создан playbook с одним сценарием reddit_app_one_play.yml;
2. Создан playbook с несколькими сценариями reddit_app_multiple_plays.yml;
3. Создано несколько playbook app.yml, db.yml, clone.yml, site.yml;
4. Изменен провижен для Packer образов 
```
    "provisioners": [
        {
            "type": "ansible",
            "playbook_file": "ansible/<playbook_name>.yml",
            "user": "appuser"
        }
    ]
```

### Задание со *

Зпдача ршена псевдо динамическим способом.
1. В terraform создан модуль out_to_ansble, который берет output значения для внешних ip адресов затем при помощи template_file и local_file формирует файл outs.json.    
2. В ansible значением по умолчанию для inventory указан скрипт который вычитывает данные из outs.json 

main.tf содуля out_to_ansble:
```
data "template_file" "user_data" {
  template = "${file("${path.module}/terraform_to_ansible.tpl")}"

  vars {
    db_ext_ip  = "${var.db_external_ip}"
    app_ext_ip = "${var.app_external_ip}"
  }
}

resource "local_file" "file" {
  content  = "${data.template_file.user_data.rendered}"
  filename = "${path.module}/outs.json"
}
```

terraform_to_ansible.tpl:
```
{
    "app": {
        "hosts": ["${app_ext_ip}"],
    },
    "db": { 
        "hosts": ["${db_ext_ip}"]
    },
        "_meta": {
            "hostvars": {}
        }
}

```

ansible.cfg
```
[defaults] 
inventory = ./dynamic_inventory.sh 
...
```

dynamic_inventory.sh:
```
#!/bin/bash
if [ "$1" = "--list" ]; then
  cat ../terraform/modules/outs_for_ansible/outs.json
elif [ "$1" = "--host" ]; then
  echo '{"_meta": {"hostvars": {}}}'
fi

```



## 13-Topic. HW Ansible-3

1. Выполнено разделение на роли
2. Создано 2 окружения stage/prod
3. Добавлена роль для nginx
4. Создан nginx прокси и соответвующее разрешение в FW (tcp:80) для приложения
5. \* Настроена динамическая инвентаризация для ansible 
6. \**Настроена проверка коммитор в репозитори:
   - packer validate
   - terraform validate и tflint
   - ansible-lint

```
install:
  - sudo pip install --upgrade pip
  - sudo pip install ansible-lint==3.4.23
  - wget https://releases.hashicorp.com/packer/1.2.5/packer_1.2.5_linux_amd64.zip && sudo unzip packer_1.2.5_linux_amd64.zip -d /usr/bin
  - wget https://github.com/wata727/tflint/releases/download/v0.7.1/tflint_linux_amd64.zip && sudo unzip tflint_linux_amd64.zip -d /usr/bin
  - wget https://releases.hashicorp.com/terraform/0.11.7/terraform_0.11.7_linux_amd64.zip && sudo unzip terraform_0.11.7_linux_amd64.zip -d /usr/bin
  - touch ~/.ssh/appuser
  - touch ~/.ssh/appuser.pub
script:
  - cd ansible/roles && ansible-lint * --exclude=jdauphant.nginx
  - cd ../../terraform/stage/ && terraform init -backend=false && terraform validate --var-file=terraform.tfvars.example && tflint --var-file=terraform.tfvars.example
  - cd ../prod && terraform init -backend=false && terraform validate --var-file=terraform.tfvars.example && tflint --var-file=terraform.tfvars.example
  - cd ../../ && find packer -name *.json -type f -print0 | xargs -0 -n1 packer validate -var-file=packer/variables.json.example 

```

7. \**Добавлен бейдж со статусом для билда ветки master  
[![Build Status](https://api.travis-ci.com/Otus-DevOps-2018-05/eogladkih_infra.svg?branch=master)](https://api.travis-ci.com/Otus-DevOps-2018-05/eogladkih_infra)    



## 14-Topic. HW Ansible-4

1. Установлен и настроен Vagrant
2. В vagrantfile внесены изменения для nginx
```
       ansible.extra_vars = {
        "deploy_user" => "vagrant",
        "nginx_sites": {
          "default": [
            "listen 80",
            "server_name reddit",
            "location / {
              proxy_pass http://127.0.0.1:9292;
            }"]
        }
      }
```

3. При помощи molecule протестирована роль db 
4. Дописан тест для проверки доступности порта mongodb
```
# check if tcp 27017 listening 
def test_mongo_port(host):
    port = host.socket('tcp://0.0.0.0:27017')
    assert port.is_listening
```
5. Настроеа сборка образов packer при помощи соответсвующих ролей
```
    "provisioners": [
        {
            "type": "ansible",
            "playbook_file": "ansible/playbooks/packer_db.yml",
            "user": "appuser",
            "extra_arguments": ["--tags", "install"],
            "ansible_env_vars": ["ANSIBLE_ROLES_PATH={{ pwd }}/ansible/roles"]
        }
    ]
```

```
- name: Add repo and install mongod
  hosts: all
  become: true
  roles:
    - db
```
