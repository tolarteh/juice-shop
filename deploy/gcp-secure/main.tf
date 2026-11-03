# Juice Shop SEGURO (fix IDOR) en Cloud Run, junto al vulnerable
variable "project_id" { default = "juice-shop-lab-2026" }
variable "region"     { default = "us-central1" }

provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_artifact_registry_repository" "repo" {
  repository_id = "juice-shop"
  location      = var.region
  format        = "DOCKER"
}

resource "google_cloud_run_v2_service" "secure" {
  name                = "juice-shop-secure"
  location            = var.region
  deletion_protection = false
  ingress             = "INGRESS_TRAFFIC_ALL"

  template {
    scaling {
      min_instance_count = 1
      max_instance_count = 1 # tope de costo
    }
    containers {
      image = "${var.region}-docker.pkg.dev/${var.project_id}/juice-shop/juice-shop-secure:latest"
      ports { container_port = 3000 }
      resources { limits = { cpu = "1", memory = "1Gi" } }
    }
  }
  depends_on = [google_artifact_registry_repository.repo]
}

resource "google_cloud_run_v2_service_iam_member" "public" {
  name     = google_cloud_run_v2_service.secure.name
  location = var.region
  role     = "roles/run.invoker"
  member   = "allUsers"
}

output "url" { value = google_cloud_run_v2_service.secure.uri }
