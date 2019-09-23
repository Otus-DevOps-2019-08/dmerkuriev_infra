# dmerkuriev_infra
dmerkuriev Infra repository

# HomeWork 3 (Cloud Bastion)
---

**В рамках задания было сделано:**
---

1. Зарегистрирована учетная запись в GCP.
2. Добавлен ssh ключ.
3. Созданы 2 VM.(Bastion c WAN и LAN сетевыми интерфейсами, 
Someinternalhost с LAN интерфейсом).
4. Проработаны различные способы подключение к VM по ssh с авторизацией по ключам.
5. Установлен VPN-сервер pritunl. Настроена марщрутизация в локальную сеть с VM. VPN соединение проверено c клиентского ПК. Настроено использование валидного ssl по средствам lets encrypt и sslip.io.

**проверка работоспособности:**
---
необходимо перейти по ссылке: https://34.76.16.142.sslip.io/

**данные для подключения:**
--- 
bastion_IP = 34.76.16.142

someinternalhost_IP = 10.132.0.8

**подключение к someinternalhost одной командой**
---
	* ssh -t -i ~/.ssh/appuser -A appuser@34.76.16.142 ssh 10.132.0.8
	* ssh -o ProxyCommand="ssh -i ~/.ssh/appuser appuser@34.76.16.142 nc %h %p" appuser@10.132.0.8

**подключение командой ssh someinternalhost**
---
Для реализации подключения командой ssh someinternalhost необходимо в файле ~/.ssh/config прописать Host

	Host someinternalhost
	HostName 34.76.16.142
	Port 22
	User appuser
	Identityfile ~/.ssh/appuser
	RequestTTY force
	RemoteCommand ssh 10.132.0.8
	ForwardAgent yes
	
После этого можно будет подключиться к someinternal host введя команду: ssh someinternalhost

	DM:~ dm$
	DM:~ dm$ ssh someinternalhost
	Welcome to Ubuntu 16.04.6 LTS (GNU/Linux 4.15.0-1042-gcp x86_64)
	
 	* Documentation:  https://help.ubuntu.com
 	* Management:     https://landscape.canonical.com
 	* Support:        https://ubuntu.com/advantage
	
	0 packages can be updated.
	0 updates are security updates.
	
	Last login: Thu Sep 19 12:49:01 2019 from 10.132.0.9
	appuser@someinternalhost:~$
	appuser@someinternalhost:~$




# HomeWork 3 (Cloud Bastion)
---

**В рамках задания было сделано:**
---
1. Установлен и настроен gcloud.
2. Создана VM с помощью gcloud.
3. На VM установлены ruby, MongoDB и развернуто тестовое приложение.
4. Команды по настройке системы и деплою приложения завернуты в bash скрипты.
5. Отработана установка и настройка VM с помощью startup-script.
6. Создан bucket для хранения startup-script.sh.
7. Открыт порт в фаерволе GCP с помощью gcloud.

**данные для подключения:**
--- 
testapp_IP = 35.210.224.4

testapp_port = 9292

**проверка работоспособности:**
---
необходимо перейти по ссылке: http://35.210.224.4:9292

**команда для создания VM с настройкой системы и деплоем приложения с помощью startup-script размещенного локально:**
---
	gcloud compute instances create reddit-app\
  		--boot-disk-size=10GB \
  		--image-family ubuntu-1604-lts \
  		--image-project=ubuntu-os-cloud \
  		--machine-type=g1-small \
  		--tags puma-server \
  		--restart-on-failure \
  		--metadata-from-file startup-script=startup-script.sh

**команда для создания VM с настройкой системы и деплоем приложения с помощью startup-script-url:**
---
	gcloud compute instances create reddit-app\
  		--boot-disk-size=10GB \
  		--image-family ubuntu-1604-lts \
  		--image-project=ubuntu-os-cloud \
  		--machine-type=g1-small \
  		--tags puma-server \
  		--restart-on-failure \
  		--metadata startup-script-url=https://storage.googleapis.com/otus-reddit-app/startup-script.sh

**команда для создания правила фаервола с помощью gcloud:**
---
	gcloud compute firewall-rules create default-puma-server \
    	--action allow \
    	--direction ingress \
    	--rules tcp:9292 \
    	--source-ranges 0.0.0.0/0 \
    	--target-tags puma-server