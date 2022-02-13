variable "default_aws_region" {    
	description = "AWS Region"
	type 	    = string
    default 	= "eu-central-1"
}

variable "common_tags" {
	description = "Common tags to apply to all resources"
	type  		= map
	default = {
		Owner   = "Sergei Larin"
		Project = "EPAM homework"
		Managed_by  = "Managed by terraform"
		Email = "sergei_larin@epam.com"
	}
}

variable "ports" {
	description = "nginx ports"
	type 	    = list
    default     = ["80", "443"]
}

# ---------------------------------------------------------------------------------------------------------------------
# DATABASE
# ---------------------------------------------------------------------------------------------------------------------

variable "db_username" {
  description = "Master username of the DB"
  type        = string
  default     = "masterdb"
}

variable "db_name" {
  description = "Name of the database to be created"
  type        = string
  default     = "homework"
}

variable "rds_pass_key" {
  description = "Name of the rds password to be created"
  type        = string
  default     = "/database/password/master"
}
variable "name" {
  description = "Name of the database"
  type        = string
  default     = "pgsql"
}

variable "engine_name" {
  description = "Name of the database engine"
  type        = string
  default     = "postgres"
}

variable "engine_version" {
  description = "Version of the database to be launched"
  default     = "14.1"
  type        = string
}

variable "family" {
  description = "Family of the database"
  type        = string
  default     = "postgres14"
}

variable "port" {
  description = "Port which the database should run on"
  type        = number
  default     = 5432
}

variable "allocated_storage" {
  description = "Disk space to be allocated to the DB instance"
  type        = number
  default     = 5
}

variable "instance_class" {
  description = "Instance class to be used to run the database"
  type        = string
  default     = "db.t3.micro"
}
