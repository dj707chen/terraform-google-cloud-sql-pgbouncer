provider "google" {}

provider "google-beta" {}

locals {
  region = join("-", slice(split("-", var.zone), 0, 2))
}

resource "random_id" "suffix" {
  byte_length = 5
}

data "google_compute_subnetwork" "subnet" {
  project = var.project
  name    = var.subnetwork_name
  region  = local.region
}

/* Database ----------------------------------------------------------------- */

module "private_service_access" {
  source  = "GoogleCloudPlatform/sql-db/google//modules/private_service_access"
  version = ">=5.0.0"

  project_id  = var.project
  vpc_network = var.network_name
}

