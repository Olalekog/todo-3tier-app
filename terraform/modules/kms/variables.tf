variable "description" {
  description = "Description for the KMS key."
  type        = string
}

variable "alias_name" {
  description = "Optional alias for the KMS key, e.g. alias/my-key."
  type        = string
  default     = ""
}

variable "deletion_window_in_days" {
  description = "KMS key deletion window in days."
  type        = number
  default     = 7
}

variable "enable_key_rotation" {
  description = "Enable annual automatic key rotation."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to apply to KMS resources."
  type        = map(string)
  default     = {}
}
