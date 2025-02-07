terraform {
  required_providers {
    random = {
      source = "hashicorp/random"
      version = "3.6.0"
    }

    spacelift = {
      source = "spacelift-io/spacelift"
      version = "1.19.1"
    }
  }
}

variable "length" {
  default = 16
  type = number
  description = "Length of a secret"
}

resource "random_password" "password" {
  length           = var.length
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

output "password" {
  value = random_password.password.result
  sensitive = true
}