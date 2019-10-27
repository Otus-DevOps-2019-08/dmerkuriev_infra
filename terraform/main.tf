terraform {
  # Версия terraform
  required_version = "~> 0.12"
}

provider "google" {
  # Версия провайдера
  version = "2.15"

  # ID проекта
  project = var.project
  region  = var.region
}

resource "google_compute_project_metadata_item" "ssh-keys" {
  key   = "ssh-keys"
  #value = "appuser:${file(var.public_key_path)} appuser1:${file(var.public_key_path)} appuser2:${file(var.public_key_path)}"
  value = "appuser:${file(var.public_key_path)}"
}

resource "google_compute_instance" "app" {
  count        = "${var.instance_count}"
  name         = "reddit-app-${count.index}"
  machine_type = "g1-small"
  zone         = var.zone
  boot_disk {
    initialize_params {
      image = var.disk_image
    }
  }
  tags = ["reddit-app"]

  network_interface {
    network = "default"
    access_config {}
  }

  #metadata = {
  #  # путь до публичного ключа
  #  ssh-keys = "appuser:${file(var.public_key_path)}"
  #}

  connection {
    type  = "ssh"
    host  = self.network_interface[0].access_config[0].nat_ip
    user  = "appuser"
    agent = false
    # путь до приватного ключа
    private_key = file(var.private_key_path)
  }

  provisioner "file" {
    source      = "files/puma.service"
    destination = "/tmp/puma.service"
  }

  provisioner "remote-exec" {
    script = "files/deploy.sh"
  }
}

resource "google_compute_firewall" "firewall_puma" {
  name = "allow-puma-default"
  # Название сети, в которой действует правило
  network = "default"
  # Какой доступ разрешить
  allow {
    protocol = "tcp"
    ports    = ["9292"]
  }
  # Каким адресам разрешаем доступ
  source_ranges = ["0.0.0.0/0"]
  # Правило применимо для инстансов с перечисленными тэгами
  target_tags = ["reddit-app"]
}

resource "google_compute_firewall" "firewall_ssh" {
  name = "default-allow-ssh"
  network = "default"
  description = "allow ssh for all"
  allow {
    protocol = "tcp"
    ports = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_address" "app_ip" {
  name = "reddit-app-ip"
}

