variable "cluster_name" {
  description = "AKS cluster name."
  type        = string
  default     = "standard-aks"
}

variable "dns_prefix" {
  description = "DNS prefix for AKS."
  type        = string
  default     = "standard-aks"
}

variable "node_count" {
  description = "Number of AKS nodes."
  type        = number
  default     = 2
}

variable "node_vm_size" {
  description = "VM size for AKS nodes."
  type        = string
  #default     = "Standard_D4s_v3"
}
