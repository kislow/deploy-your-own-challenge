output "databases" {
  value = {
    for k, m in module.databases :
    k => m.connection_string
  }
}

output "apps" {
  value = {
    for k, m in module.apps :
    k => m.container_name
  }
}
