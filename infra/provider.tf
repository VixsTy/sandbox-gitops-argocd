provider "google-beta" {
  project = var.google_project
  region  = var.google_region

  version = "~> 3.29"
}

# provider "kubernetes" {
#   version = "~> 1.11"
# }
