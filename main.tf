terraform {
  required_providers {
    random = {
      source = "hashicorp/random"
      version = "3.6.0"
    }
  }
}

resource "spacelift_mounted_file" "core-kubeconfig" {
  stack_id      = "tofuone"
  relative_path = "test-file"
  content       = filebase64("${path.module}/xyz")
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