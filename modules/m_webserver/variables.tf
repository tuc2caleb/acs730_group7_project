variable "instance_type" {
  default = {
   
  }
  description = "Type of the instance"
  type        = map(string)
}

# Default tags
variable "default_tags" {
  default = {
   
  }
  type        = map(any)
  description = "Default tags to be appliad to all AWS resources"
}

# Prefix to identify resources
variable "prefix" {
  
  type        = string
  description = "Name prefix"
}


# Variable to signal the current environment 
variable "env" {

  type        = string
  description = "Deployment Environment"
}

