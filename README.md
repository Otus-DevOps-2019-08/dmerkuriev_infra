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
необходимо перейти по ссылке: [https://34.76.16.142.sslip.io/] ()

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

