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


variable "environment" {
  description = ""
}

#########################
#Build variables
#########################

variable "build_environment" {
  description = "Information about the project's build environment."
  type        = any
  default     = {}
}

variable "build_environment_compute_type" {
  description = "Information about the compute resources the build project will use."
  type        = string
  default     = "BUILD_GENERAL1_SMALL"
}

variable "build_environment_image" {
  description = "The Docker image to use for this build project. "
  type        = string
  default     = "aws/codebuild/amazonlinux2-x86_64-standard:3.0"
}

variable "build_build_environment_type" {
  description = "The type of build environment to use for related builds. Available values are: `LINUX_CONTAINER`, `LINUX_GPU_CONTAINER`, `WINDOWS_CONTAINER` or `ARM_CONTAINER`."
  type        = string
  default     = "LINUX_CONTAINER"
}

variable "build_environment_image_pull_credentials_type" {
  description = "The type of credentials AWS CodeBuild uses to pull images in your build. "
  type        = string
  default     = "CODEBUILD"
}

variable "build_environment_variables" {
  description = "A list of sets of environment variables to make available to builds for this build project."
  type        = list
  default     = []
}

variable "build_environment_privileged_mode" {
  description = "If set to true, enables running the Docker daemon inside a Docker container."
  type        = bool
  default     = false
}

variable "build_environment_certificate" {
  description = "The ARN of the S3 bucket, path prefix and object key that contains the PEM-encoded certificate."
  type        = string
  default     = null
}

variable "build_environment_registry_credential" {
  description = "Information about credentials for access to a private Docker registry. "
  type        = map
  default     = {}
}


locals{
  build_environment = [
    {
      compute_type                = lookup(var.build_environment, "compute_type", null) == null ? var.build_environment_compute_type : lookup(var.build_environment, "compute_type")
      image                       = lookup(var.build_environment, "image", null) == null ? var.build_environment_image : lookup(var.build_environment, "image")
      type                        = lookup(var.build_environment, "type", null) == null ? var.build_environment_type : lookup(var.build_environment, "type")
      image_pull_credentials_type = lookup(var.build_environment, "image_pull_credentials_type", null) == null ? var.build_environment_image_pull_credentials_type : lookup(var.build_environment, "image_pull_credentials_type")
      variables                   = lookup(var.build_environment, "variables", null) == null ? var.build_environment_variables : lookup(var.build_environment, "variables")
      privileged_mode             = lookup(var.build_environment, "privileged_mode", null) == null ? var.build_environment_privileged_mode : lookup(var.build_environment, "privileged_mode")
      certificate                 = lookup(var.build_environment, "certificate ", null) == null ? var.build_environment_certificate : lookup(var.build_environment, "certificate")
      registry_credential         = lookup(var.build_environment, "registry_credential", null) == null ? var.build_environment_registry_credential : lookup(var.build_environment, "registry_credential")
    }
  ]

}