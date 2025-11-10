variable "bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
}

variable "force_destroy" {
  description = "A boolean that indicates all objects should be deleted from the bucket when the bucket is destroyed"
  type        = bool
  default     = false
}

variable "enable_versioning" {
  description = "Enable versioning for the S3 bucket"
  type        = bool
  default     = true
}

variable "enable_encryption" {
  description = "Enable server-side encryption"
  type        = bool
  default     = true
}

variable "kms_key_id" {
  description = "ARN of the KMS key for encryption (leave empty for AES256)"
  type        = string
  default     = ""
}

variable "block_public_acls" {
  description = "Whether Amazon S3 should block public ACLs"
  type        = bool
  default     = true
}

variable "block_public_policy" {
  description = "Whether Amazon S3 should block public bucket policies"
  type        = bool
  default     = true
}

variable "ignore_public_acls" {
  description = "Whether Amazon S3 should ignore public ACLs"
  type        = bool
  default     = true
}

variable "restrict_public_buckets" {
  description = "Whether Amazon S3 should restrict public bucket policies"
  type        = bool
  default     = true
}

variable "lifecycle_rules" {
  description = "List of lifecycle rules"
  type        = list(any)
  default     = []
}

variable "logging_bucket" {
  description = "Name of the bucket for access logs"
  type        = string
  default     = ""
}

variable "logging_prefix" {
  description = "Prefix for access log objects"
  type        = string
  default     = "logs/"
}

variable "cors_rules" {
  description = "List of CORS rules"
  type        = list(any)
  default     = []
}

variable "bucket_policy" {
  description = "JSON policy document for the bucket"
  type        = string
  default     = ""
}

variable "enable_object_lock" {
  description = "Enable S3 Object Lock"
  type        = bool
  default     = false
}

variable "object_lock_mode" {
  description = "Object Lock retention mode (GOVERNANCE or COMPLIANCE)"
  type        = string
  default     = "GOVERNANCE"
}

variable "object_lock_days" {
  description = "Number of days for Object Lock retention"
  type        = number
  default     = null
}

variable "object_lock_years" {
  description = "Number of years for Object Lock retention"
  type        = number
  default     = null
}

variable "enable_intelligent_tiering" {
  description = "Enable S3 Intelligent-Tiering"
  type        = bool
  default     = false
}

variable "intelligent_tiering_archive_days" {
  description = "Days before moving to Archive tier"
  type        = number
  default     = 90
}

variable "intelligent_tiering_deep_archive_days" {
  description = "Days before moving to Deep Archive tier"
  type        = number
  default     = 180
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}
