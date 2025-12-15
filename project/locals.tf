locals {
  common_tags = {
    Project     = "thrivecart"
    Application = "thrive"
    Environment = var.env
    ManagedBy   = "terraform"
  }
}
