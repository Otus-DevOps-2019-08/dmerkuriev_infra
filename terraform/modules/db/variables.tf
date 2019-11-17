variable zone {
  description = "Zone"
  default     = "europe-west1-d"
}

variable public_key_path {
  # Описание переменной
  description = "Path to the public key used for ssh access"
}

# переменная для приватного ключа
variable private_key_path {
  description = "Path to the private key used for ssh access"
  default     = "~/.ssh/appuser"
}

variable db_disk_image {
  description = "Disk image for reddit db"
  default     = "reddit-db-base"
}

