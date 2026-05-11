variable "cluster_name" {
  description = "AKS cluster name."
  type        = string
  default     = "standard-aks-nap"
}

variable "dns_prefix" {
  description = "DNS prefix for AKS."
  type        = string
  default     = "standard-aks-nap"
}

variable "node_count" {
  description = "Baseline number of system nodes."
  type        = number
  default     = 1
}

variable "node_vm_size" {
  description = "VM size for baseline AKS system nodes."
  type        = string
  default     = "Standard_DC2s_v3"
}
