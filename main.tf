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
    null = {
      source = "hashicorp/null"
      version = "3.2.4"
    }
  }
}

variable "length" {
  default = 6
  type = number
  description = "Length of a secret"
}

resource "null_resource" "always_run" {
  triggers = {
    timestamp = "${timestamp()}"
  }
}

resource "random_password" "password" {
  length           = var.length
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
    lifecycle {
    replace_triggered_by = [
      null_resource.always_run
    ]
  }
  
}

output "password" {
  value = random_password.password.result
  sensitive = true
}
