variable "databases" {
  type = map(object({
    db_name  = string
    user     = string
    password = string
    port     = number
  }))
}

variable "apps" {
  type = map(object({
    image = string
    port  = number
    db    = string
  }))
}
