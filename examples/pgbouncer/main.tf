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

data "db" "d" {
  source  = "GoogleCloudPlatform/sql-db/google//modules/postgresql"
  version = ">=5.0.0"

  project_id = var.project
  name       = "db-${random_id.suffix.hex}"
}

/* PgBouncer ---------------------------------------------------------------- */

resource "google_compute_address" "pgbouncer" {
  project      = var.project
  region       = local.region
  name         = "ip-pgbouncer-${random_id.suffix.hex}"
  network_tier = "PREMIUM"
}

module "pgbouncer" {
  source = "../.."

  project           = var.project
  name              = "vm-pgbouncer-${random_id.suffix.hex}"
  zone              = var.zone
  subnetwork        = var.subnetwork_name
  public_ip_address = google_compute_address.pgbouncer.address
  tags              = ["pgbouncer"]

  disable_service_account = true

  port          = 25128
  database_host = module.db.private_ip_address

  users = [
    { name = var.db_user, password = var.db_password },
  ]

  module_depends_on = [module.db]
}

/* Firewall ----------------------------------------------------------------- */

resource "google_compute_firewall" "pgbouncer" {
  name    = "${var.network_name}-ingress-pgbouncer-${random_id.suffix.hex}"
  project = var.project
  network = var.network_name

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["pgbouncer"]

  allow {
    protocol = "tcp"
    ports    = [module.pgbouncer.port]
  }
}
