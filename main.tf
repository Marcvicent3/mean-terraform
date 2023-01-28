terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }
  required_version = ">= 0.14.9"
}

#Credenciales para conectarse a AWS
provider "aws" {
  profile    = "default"
  region     = "us-east-1"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

#Desplegando la instancia de MONGO DB 
resource "aws_instance" "mongodb" {
  ami           = var.mongo_ami
  instance_type = "t2.micro"

  vpc_security_group_ids = var.mongo_sg
  subnet_id              = var.mongo_subnet
  private_ip             = var.mongo_priv_ip
  tags = {
    Name = "MongoDB"
  }
}

#Usamos una AMI del catalogo de AWS 
data "aws_ami" "ubuntu" {
  #Usamos la version reciente
  most_recent = true
  #Colocamos el ID de la AMI
  owners = ["099720109477"]

  #Un filtro ya que el owner puede tener varias versiones de ubuntu.
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
  }
}


#Despliegue del servidor web 
resource "aws_instance" "app_server" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t2.micro"
  key_name                    = var.key_name
  subnet_id                   = var.app_subnet
  private_ip                  = var.app_priv_ip
  vpc_security_group_ids      = var.app_sg
  associate_public_ip_address = true
  tags = {
    Name = "WebServer"
  }

  # hello.js paso como parametro la ip privada para el conecction string hacia mongoDb
  provisioner "file" {
    content = <<-EOT
     const http = require('http');

     const hostname = 'localhost';
     const port = 8080;

     const server = http.createServer((req, res) => {
      res.statusCode = 200;
      res.setHeader('Content-Type', 'text/plain');
      res.end("HOLA UNIR! Soy Marcelo Romero! \nConnection string to MongoDb: mongodb://${aws_instance.mongodb.private_ip}:27017");
     });

     server.listen(port, hostname, () => {
      console.log("Server running at http://"+hostname+":"+port+"/");
     }); 
    EOT 
    #Destino del fichero
    destination = "/tmp/hello.js"

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("~/Downloads/credentials/mromero.pem")
      host        = self.public_ip
    }
  }

  #En la instancia desplegada copiamos el fichero app_setup que tiene los comandos necesarios para desplegar la aplicacion
  provisioner "file" {
    source      = "app/app_setup.sh"
    destination = "/tmp/app_setup.sh"

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("~/Downloads/credentials/mromero.pem")
      host        = self.public_ip
    }
  }

  #copiando el archivo node en la configuracion de nginx
  provisioner "file" {
    source      = "app/node"
    destination = "/tmp/node"

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("~/Downloads/credentials/mromero.pem")
      host        = self.public_ip
    }
  }

  #modifcando los permisos del script y ejecutamos
  provisioner "remote-exec" {
    inline = ["chmod +x /tmp/app_setup.sh", "/tmp/app_setup.sh", ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("~/Downloads/credentials/mromero.pem")
      host        = self.public_ip
    }
  }
}
