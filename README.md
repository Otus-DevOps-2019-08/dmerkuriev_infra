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




# HomeWork 4 (Cloud-testapp)
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


# HomeWork 5 (Packer-base)
---

**В рамках задания было сделано:**
---

1. Установлен packer, выдан доступ для packer в GCP.
2. По инструкции создан образ ubuntu c установленными mongodb и ruby. Из образа развернута VM и в нее задеплоено приложение.
3. Добавлен шаблон с переменными, файл variables.json. ID проекта, семейство образов, тип VM, описание образа, размер и тип диска, тэг сети.
4. Создан образ reddit-full, с установленными mongodb и ruby, задеплоенным приложением. Для старта приложения написан systemd unit.
5. Написан скрипт для запуска VM из командной строки с помощью утилиты gcloud файл config-scripts/create-reddit-vm.sh.

**проверка работоспособности:**
---
1. В корне репозитория выполнить команду: packer build -var-file variables.json immutable.json
2. Выполнить скрипт config-scripts/create-reddit-vm.sh.
3. Запомнить IP адрес. 
4. В браузере открыть http://IP:9292.

# HomeWork 6 (Terraform-1)
---

**В рамках задания было сделано:**
---
1. Удалили ключи пользователя appuser, для того что бы настроить добавление ключей с помощью terraform.
2. Установили terraform.
3. Создали конфигурационный файл **main.tf** - декларативное описание инфраструктуры. Описали в нем провайдера (GCP) и описали ресурсы для создания VM.
4. Создали VM из образа reddit-base. Посмотрели tfstate, c помощью grep получили из него IP-адрес VM.
5. Создали файл **outputs.tf** в котором описали выходную переменную "app\_external_ip", которая возвращает в консоль IP адрес VM после ее создания.
6. Добавили ресурс с правилом фаерволла для нашего приложения.
7. Добавили provisioners: deploy.sh скрипт деплоя приложения, puma.service systemd unit для сервера puma.
8. Прописали параметры подключения provisioners.
9. С помощью команды taint пересоздали VM. 
10. Проверили работу приложения открыв в браузере.
11. Создали файл **variables.tf** в котором определили входные переменные.
12. Определили с помощью переменных параметры ресурсов в main.tf.
13. Определили переменные в файле **terraform.tfvars**.
14. Удалили и заново создали ресурсы. Проверили работоспособность.

**Самостоятельная работа**
---
* Определите input переменную для приватного ключа,
использующегося в определении подключения для
провижинеров (connection).

В variables.tf добавляем строки:

	variable private_key_path {
	  description = "Path to the private key used for ssh access"
	}
	
В terraform.tfvars добавляем строки:

	private_key_path = "~/.ssh/appuser"
	
В main.tf добавляем строки:

	connection {
	  type  = "ssh"
      host  = self.network_interface[0].access_config[0].nat_ip
      user  = "appuser"
      agent = false
      # путь до приватного ключа
      private_key = file(var.private_key_path)
    }

* Определите input переменную для задания зоны в ресурсе
"google\_compute_instance" "app". У нее должно быть значение
по умолчанию;

В variables.tf добавляем строки:

	variable zone {
  	  description = "Zone"
  	  default     = "europe-west1-d"
	}
В main.tf добавляем строки:

	resource "google_compute_instance" "app" {
	...
	  zone         = var.zone	
	...  
	}
* Отформатируйте все конфигурационные файлы используя
команду terraform fmt;

Конфигурационные файлы отформатированы.

* Так как в репозиторий не попадет ваш terraform.tfvars, то
нужно сделать рядом файл terraform.tfvars.example, в
котором будут указаны переменные для образца.

Создан файл terraform.tfvars.example со следующим содержанием:

	project          = "Project ID"
	public_key_path  = "~/.ssh/appuser.pub"
	private_key_path = "~/.ssh/appuser"
	disk_image       = "Image"

**Задание с** *
---
* Опишите в коде терраформа добавление ssh ключа пользователя
appuser1 в метаданные проекта. Выполните terraform apply и
проверьте результат (публичный ключ можно брать пользователя
appuser).

В main.tf прописано:

	metadata = {
	# путь до публичного ключа
	  ssh-keys = "appuser1:${file(var.public_key_path)}"
	}
После применения terraform apply ключ пользователя appuser1 появился в VM и появилась возможность зайти под ним по ssh на VM.

* Опишите в коде терраформа добавление ssh ключей нескольких
пользователей в метаданные проекта (можно просто один и тот
же публичный ключ, но с разными именами пользователей,
например appuser1, appuser2 и т.д.). Выполните terraform apply и проверьте результат.

В main.tf прописано:

	metadata = {
	# путь до публичного ключа
	  ssh-keys = "appuser:${file(var.public_key_path)} appuser1:${file(var.public_key_path)} appuser2:${file(var.public_key_path)}"
	}
После применения terraform apply ключи пользователей appuser, appuser1, appuser2 появились в VM и появилась возможность зайти под ними по ssh на VM.

* Добавьте в веб интерфейсе ssh ключ пользователю appuser_web
в метаданные проекта. Выполните terraform apply и проверьте
результат.

Добалвен ключ пользователя appuser-web в веб-интерфейс, в метаданные проекта. После применения tarraform apply ключ был удален.

* Какие проблемы вы обнаружили?

Ключ пользователя appuser_web был удален terraform, так как мы его добавили через веб-интерфейс и информации о нем не было в конфигурационных файлах и tfstate.

**Задание с** **
---
* Создайте файл lb.tf и опишите в нем в коде terraform создание HTTP балансировщика, направляющего трафик на наше
развернутое приложение на инстансе reddit-app. Проверьте
доступность приложения по адресу балансировщика. Добавьте в
output переменные адрес балансировщика.

Создан файл lb.tf с конфигурацией балансировщика:

	resource "google_compute_forwarding_rule" "lb-fw" {
	  name                  = "reddit-app"
	  description           = "Forwarding rule for Reddit apps"
	  port_range            = "9292"
	  target                = "${google_compute_target_pool.lb.self_link}"
	  load_balancing_scheme = "EXTERNAL"
	}
	
	resource "google_compute_target_pool" "lb" {
	  name          = "reddit-lb"
	  description   = "Load balancer for Reddit apps"
	  instances     = "${google_compute_instance.app.*.self_link}"
	  health_checks = ["${google_compute_http_health_check.default.name}"]
	}
	
	resource "google_compute_http_health_check" "default" {
	  name                = "reddit-app-hc"
	  port                = 9292
	  check_interval_sec  = 5
	  timeout_sec         = 5
	  healthy_threshold   = 2
	  unhealthy_threshold = 5
	} 
В outputs.tf добавлена переменная, возвращающая IP адрес балансировщика:

	output "lb_external_ip" {
	  value = google_compute_forwarding_rule.lb-fw.ip_address
	}

* Добавьте в код еще один terraform ресурс для нового инстанса
приложения, например reddit-app2, добавьте его в балансировщик и проверьте, что при остановке на одном из инстансов приложения (например systemctl stop puma), приложение продолжает быть доступным по адресу балансировщика; Добавьте в output переменные адрес второго инстанса; Какие проблемы вы видите в такой конфигурации приложения? 
* Как мы видим, подход с созданием доп. инстанса копированием
кода выглядит нерационально, т.к. копируется много кода.
Удалите описание reddit-app2 и попробуйте подход с заданием
количества инстансов через параметр ресурса count.
Переменная count должна задаваться в параметрах и по
умолчанию равна 1.

В variables.tf добавлена переменная:

	variable instance_count {
	  description = "Number of instances"
	  default     = "1"
	}

В main.tf описаны параметры создания VM.

	resource "google_compute_instance" "app" {
	  count        = "${var.instance_count}"
	  name         = "reddit-app-${count.index}"
	...
	}
	
В outputs.tf скорректированна переменная возвращающая IP адреса всех созданных VM.

	output "app_external_ip" {
  	  value = google_compute_instance.app[*].network_interface[0].access_config[0].nat_ip
	}
После применения terraform apply, были созданы балансировщик и 2 VM. Проверена доступность приложения на IP адресе балансировщика. Приложение оставалось доступным после выключения сервера puma на одной из VM.

# HomeWork 7 (Terraform-2)
---

**В рамках задания было сделано:**
---
1. В репозитории создана новая ветка terraform-2.
2. Количество инстансов из прошлого задания установлено равным 1. Файл **lb.tf** перенесен в **terraform/files**.
3. В **main.tf** создан ресурс **"google_compute\_firewall" "firewall-ssh"** управляющий правилом файерволом для подключения по ssh.

		resource "google_compute_firewall" "firewall_ssh" {
	  	  name = "default-allow-ssh"
	  	  network = "default"
		
	  	  allow {
	       protocol = "tcp"
	       ports = ["22"]
	  	  }
	  
	  	  source_ranges = ["0.0.0.0/0"]
		}
4. В state файл импортирована информация о ресурсе **"google_compute\_firewall" "firewall-ssh"**.

		$ terraform import google_compute_firewall.firewall_ssh default-allow-ssh
5. В **main.tf** определен ресурс **"google_compute\_address"** в котором задан IP адрес для инстанса с приложением.

		resource "google_compute_address" "app_ip" {
		  name = "reddit-app-ip"
		}
В описании конфигурации VM добавлена ссылка на атрибут ресурса, который создает этот IP.

		network_interface {
		  network = "default"
		  access_config {
		    nat_ip = google_compute_address.app_ip.address
		  }
		} 

6. В директории **packer** созданы два новых шаблона: **db.json** - собирается образ VM, содержащий установленную MongoDB, **app.json** - собирается образ VM, содержащий установленный Ruby.
7. Конфиг **main.tf** разбит на два новых конфига: **app.tf** - вынесена конфигурация VM с приложением, **db.tf** - вынесена конфигурация базы.
8. В файл **vpc.tf** вынесено правило фаервола для доступа по ssh, которое применимо для всех инстансов.
9. Конфигурация разбита на модули. Созданы каталоги **modules/db**, **modules/app**.
В файл **main.tf**, где определен провайдер вставлены секции вызова созданных нами модулей:

		...
		module "app" {
		  source = "modules/app"
		  public_key_path = var.public_key_path
		  zone = var.zone
		  app_disk_image = var.app_disk_image
		}
		
		module "db" {
		  source = "modules/db"
		  public_key_path = var.public_key_path
		  zone = var.zone
		  db_disk_image = var.db_disk_image
		}
Для начала использования module их нужно загрузить командой **terraform get**.


10. Создан модуль **module/vpc** с описанием конфигурации фаервола. modules/vpc/main.tf:
		
		resource "google_compute_firewall" "firewall_ssh" {
  		  name    = "default-allow-ssh"
  		  network = "default"

  		  allow {
    	    protocol = "tcp"
    	    ports    = ["22"]
  		  }

  		  source_ranges = var.source_ranges
		}


11. Для переиспользования модулей, в каталоге **terraform** созданы два каталога **stage** и **prod**.
С помощью модуля **vpc**, в окружении **stage** открыт ssh доступ с любого ip адреса:

		module "vpc" {
  		  source          = "../modules/vpc"
  		  source_ranges   = ["0.0.0.0/0"]
		}
С помощью модуля **vpc**, в окружении **prod** открыт ssh доступ только с частного ip адреса:

		module "vpc" {
  		  source          = "../modules/vpc"
  		  source_ranges   = ["8.8.8.8/32"]
		}

12. С помощью модуля **storage-bucket**, в каталоге terraform создан файл **storage-bucket.tf** c описанием создания бакета в сервисе Storage.

		provider "google" {
  		  version = "~> 2.15"
  		  project = var.project
  		  region  = var.region
		}

		module "storage-bucket" {
  		  source  = "SweetOps/storage-bucket/google"
  		  version = "0.3.0"

  		  name = "storage-bucket-terraform-test-dm"
  		  location = var.region
		}

		output storage-bucket_url {
  		  value = module.storage-bucket.url
		}


**Задание с** *
---
* Настройте хранение стейт файла в удаленном бекенде (remote backends) для окружений stage и prod, используя Google Cloud Storage в качестве бекенда. Описание бекенда нужно вынести в отдельный файл backend.tf

В каталогах **prod** и **stage** созданы файлы **backend.tf** следующего содержания:

prod/backend.tf

	terraform {
  	  backend "gcs" {
  	    bucket = "storage-bucket-terraform-test-dm"
  	    prefix = "terraform/prod"
  	  }
	}

stage/backend.tf

	terraform {
	  backend "gcs" {
	    bucket = "storage-bucket-terraform-test-dm"
	    prefix = "terraform/stage"
	  }
	}

Удален state файл. 

Проверено, что после инициализации terraform в окружении stage и prod, state берерться из созданного бакета. Одновременное изменение конфигурации не работает, так как state-файл заблокирован во избежании перезаписи несколькими пользователями в один момент времени.

**Задание с** **
---
* В процессе перехода от конфигурации, созданной в
предыдущем ДЗ к модулям мы перестали использовать provisioner
для деплоя приложения. Соответственно, инстансы поднимаются
без приложения.
* Добавьте необходимые provisioner в модули для деплоя и работы
приложения. Файлы, используемые в provisioner, должны
находится в директории модуля.

В модуль **DB** в **db/main.tf** добавлен блок **connection**, в котором описано подключение по ssh. Добавлен **provisioner** который меняет конфиг mongod, что бы тот слушал не только localhost и перезапускает mongod.

	...
	connection {
	  type        = "ssh"
	  user        = "appuser"
	  agent       = false
	  private_key = file(var.private_key_path)
	  host = self.network_interface[0].access_config[0].nat_ip
  	}
  
	provisioner "remote-exec" {
    inline = [
      "sudo sed -i 's/bindIp: 127.0.0.1/bindIp: 0.0.0.0/' /etc/mongod.conf",
      "sudo systemctl restart mongod"
    ]
    }
В **db/outputs.tf** добавлена переменная **mongod_ip** указывающая на внутренний IP адрес VM с mongod.
	
	...
	output "mongod_ip" {
	  value = google_compute_instance.db.network\_interface.0.network\_ip
	}

В модуль **APP** в **app/main.tf** добавлен блок **connection**, в котором описано подключение по ssh. Добавлены **provisioners** которые: экспортируют переменную **DATABASE_URL** в переменные окружающей среды, копируют **puma.service** файл, запускают деплой приложения с помощью скрипта **deploy.sh**.

	...
	connection {
	  type        = "ssh"
	  host        = google_compute_address.app_ip.address
	  user        = "appuser"
	  agent       = false
	  private_key = file(var.private_key_path)
	}
	
	provisioner "remote-exec" {
	  inline = ["echo export DATABASE_URL=\"${var.mongod_ip}\" >> ~/.profile"]
	}
	
	provisioner "file" {
	  source      = "${path.module}/files/puma.service"
	  destination = "/tmp/puma.service"
	}
	
	provisioner "remote-exec" {
	  script = "${path.module}/files/deploy.sh"
	}



Проведена проверка работы приложения и БД.
	
	terraform apply
	...
	...
	Apply complete! Resources: 6 added, 0 changed, 0 destroyed.

	Outputs:

	app_external_ip = [
  	  "35.210.40.235",
	]
	mongod_ip = 10.132.15.197
	
После чего можно проверить работоспособность приложения открыв в браузере адрес **http://35.210.40.235:9292**