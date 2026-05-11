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

variable "min_count" {
  description = "Minimum number of AKS nodes for autoscaling."
  type        = number
  default     = 1
}

variable "max_count" {
  description = "Maximum number of AKS nodes for autoscaling."
  type        = number
  default     = 3
}

variable "node_vm_size" {
  description = "VM size for AKS nodes."
  type        = string
  #default     = "Standard_D4s_v3"
}
