variable "tenancy_ocid" {
  description = "OCID of your OCI tenancy."
  type        = string
}

variable "user_ocid" {
  description = "OCID of the OCI user Terraform authenticates as."
  type        = string
}

variable "fingerprint" {
  description = "Fingerprint of the API signing key uploaded to the OCI user."
  type        = string
}

variable "private_key_path" {
  description = "Path to the private API signing key on disk."
  type        = string
  default     = "~/.oci/oci_api_key.pem"
}

variable "compartment_id" {
  description = "OCID of the compartment to create resources in (defaults to the tenancy root compartment if unset elsewhere)."
  type        = string
}

variable "region" {
  description = "OCI region to deploy into. uk-london-1 is the London region."
  type        = string
  default     = "uk-london-1"
}

variable "availability_domain_number" {
  description = "Index (0-based) into the region's list of availability domains to deploy into."
  type        = number
  default     = 0
}

variable "instance_shape" {
  description = "Compute shape. VM.Standard.A1.Flex is the Always Free ARM shape; VM.Standard.E2.1.Micro is the Always Free x86 shape (use this if A1 capacity isn't available in uk-london-1)."
  type        = string
  default     = "VM.Standard.A1.Flex"
}

variable "instance_ocpus" {
  description = "OCPUs for a flex shape. Ignored for fixed shapes like VM.Standard.E2.1.Micro. Always Free covers up to 4 total A1 OCPUs (2 as of the June 2026 tier reduction) across all A1 instances in the tenancy."
  type        = number
  default     = 1
}

variable "instance_memory_in_gbs" {
  description = "Memory (GB) for a flex shape. Ignored for fixed shapes. Always Free covers up to 24GB total A1 memory (12GB as of the June 2026 tier reduction)."
  type        = number
  default     = 6
}

variable "ssh_public_key_path" {
  description = "Path to the SSH public key to install on the instance."
  type        = string
  default     = "~/.ssh/id_ed25519.pub"
}

variable "ssh_allowed_cidr" {
  description = "CIDR allowed to reach the instance on port 22. Restrict this to your own IP where possible."
  type        = string
  default     = "0.0.0.0/0"
}

variable "tailscale_auth_key" {
  description = "Tailscale auth key used to register this node non-interactively (see https://login.tailscale.com/admin/settings/keys). Leave empty to run `tailscale up` manually after boot instead."
  type        = string
  default     = ""
  sensitive   = true
}

variable "instance_display_name" {
  description = "Display name for the compute instance."
  type        = string
  default     = "tailscale-exit-node-uk"
}
