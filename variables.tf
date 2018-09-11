variable "enabled" {
  description = "Conditionally enable/disable the module"
  default     = true
}

variable "url" {
  description = "The GCS url name, beginning with a gs://, can be either a bucket or an object."
}

variable "action" {
  description = "The acl action to perform: currently only supports 'ch'"
  default     = "ch"
}

variable "entity_type" {
  description = "The entity type: u|g|p|d"
}

variable "entity" {
  description = "The entity compatible with the given entity type"
}
