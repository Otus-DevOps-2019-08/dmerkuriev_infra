variable project {
  description = "Project ID"
}
variable region {
  description = "Region"
  # Значение по умолчанию
  default = "europe-west1"
}
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
}
variable disk_image {
  description = "Disk image"
}
variable instance_count {
  description = "Number of instances"
  default     = "1"
}
