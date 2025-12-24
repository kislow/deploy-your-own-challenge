module "databases" {
  source = "git::https://github.com/kislow/tmp.git//repo-0d257749f664a9/terraform-local/modules/database?<REFERENCE_MODULE_AND_BRANCH_OR_TAG🫡>"

  # TODO:
  # You are given multiple databases via var.databases
  # This module only deploys ONE database
  # Make this work for ALL databases

  name     = "example"
  db_name  = "example"
  user     = "example"
  password = "example"
  port     = 5432
}


module "apps" {
  source   = "git::https://github.com/kislow/tmp.git//repo-0d257749f664a9/terraform-local/modules/<REFERENCE_MODULE_AND_BRANCH_OR_TAG🫡>"

  # TODO:
  # You are given multiple apps via var.apps
  # Make this work for ALL apps

  name           = "example"
  image          = "example"
  external_port  = "example"
  database_url   = module.databases[each.value.db].connection_string
}
