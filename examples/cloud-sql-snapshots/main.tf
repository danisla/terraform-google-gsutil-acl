variable "write_url" {}
variable "read_url" {}

variable "acl_action" {
  default = "add"
}

variable "name" {
  default = "cloud-sql-acl-example"
}

variable "region" {
  default = "us-central1"
}

provider "google" {
  region = "${var.region}"
}

data "google_client_config" "current" {}

resource "random_id" "name" {
  byte_length = 2
}

locals {
  project           = "${data.google_client_config.current.project}"
  name              = "${var.name}-${random_id.name.hex}"
  instance_sa_email = "${module.instance_sa_email.sa_email}"
}

module "db-instance" {
  source           = "GoogleCloudPlatform/sql-db/google"
  version          = "1.0.1"
  project          = "${local.project}"
  name             = "${local.name}"
  database_version = "MYSQL_5_6"
  tier             = "db-f1-micro"
  user_name        = "admin"
  disk_size        = "10"
  disk_type        = "PD_SSD"
}

module "instance_sa_email" {
  source   = "github.com/danisla/terraform-google-sql-sa-email"
  instance = "${basename(module.db-instance.self_link)}"
  project  = "${data.google_client_config.current.project}"
}

# Add write permission for Cloud SQL service account.
module "write-acl" {
  source      = "../../"
  enabled     = "${var.acl_action == "add"}"
  url         = "${var.write_url}"
  action      = "ch"
  entity_type = "u"
  entity      = "${local.instance_sa_email}:WRITER"
}

module "del-write-acl" {
  source      = "../../"
  enabled     = "${var.acl_action == "del"}"
  url         = "${var.write_url}"
  action      = "ch"
  entity_type = "d"
  entity      = "${local.instance_sa_email}"
}

# Add read permission for Cloud SQL service account
module "read-acl" {
  source      = "../../"
  enabled     = "${var.acl_action == "add"}"
  url         = "${var.read_url}"
  action      = "ch"
  entity_type = "u"
  entity      = "${local.instance_sa_email}:READER"
}

module "del-read-acl" {
  source      = "../../"
  enabled     = "${var.acl_action == "del"}"
  url         = "${var.read_url}"
  action      = "ch"
  entity_type = "d"
  entity      = "${local.instance_sa_email}"
}

output "instance_name" {
  value = "${module.db-instance.instance_name}"
}
