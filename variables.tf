# Credenciales AWS
variable "aws_access_key" {
  type = string
  default = "*"
}

variable "aws_secret_key" {
  type = string
  default = "*"
}


variable "key_name" {
  type = string
  default = "mromero"
}
# VARIABLES DE MONGODB

variable "mongo_ami" {
  type    = string
  default = "ami-0019f1e85386a77e1"
}

variable "mongo_sg" {
  type    = list(string)
  default = ["sg-06d199b669a8ae269"]
}
variable "mongo_subnet" {
  type    = string
  default = "subnet-02783539eec48139f"
}

variable "mongo_priv_ip" {
  type    = string
  default = "172.31.2.25"
}



# Application variables
variable "app_priv_ip" {
  type    = string
  default = "172.31.3.15"
}

variable "app_sg" {
  type    = list(string)
  default = ["sg-04476b5bd706a9127"]
}
variable "app_subnet" {
  type    = string
  default = "subnet-0e20c56ea93d78ec5"
}
