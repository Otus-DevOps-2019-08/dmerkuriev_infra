output "app_external_ip" {
  value = module.app.app_external_ip
}

output "mongod_ip" {
  value = "${module.db.mongod_ip}"
}

