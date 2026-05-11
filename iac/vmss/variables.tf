variable "admin_username" {
  description = "The admin username for the virtual machine."
  type        = string
}

variable "instance_count" {
  description = "Number of VMSS instances."
  type        = number
  default     = 2
}

variable "vmss_sku" {
  description = "VM size for the scale set instances."
  type        = string
  default     = "Standard_B1s"
}
