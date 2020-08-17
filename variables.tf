variable "name" {
  description = "The Name of the application or solution"
}

variable "tags" {
  type        = "map"
  default     = {}
  description = "Additional tags (e.g. `map('BusinessUnit','XYZ')`)"
}

variable "buildspec" {
  type        = "string"
  description = ""
  default     = "buildspec.yml"
}

variable "connection_arn" {
  type        = "string"
  description = ""
}

variable "respository_id" {
  description = ""
}

variable "branch_name" {
  description = ""
}

variable "s3_bucket_hosting_name" {
  description = "Name of the hosted zone to contain the record"
  default     = ""
}

variable "s3_bucket_hosting_arn" {
  description = "Name of the hosted zone to contain the record"
  default     = ""
}

variable "environment" {
  description = ""
}