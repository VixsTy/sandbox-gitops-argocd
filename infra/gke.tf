resource "google_container_cluster" "primary" {
  provider = google-beta

  name     = "argocd-${terraform.workspace}-cluster"
  location = var.google_zone
  project  = var.google_project

  remove_default_node_pool = true
  initial_node_count       = 1

  addons_config {
    istio_config {
      disabled = false
    }
  }

  release_channel {
    channel = "RAPID"
  }

  network_policy {
    enabled  = true
    provider = "CALICO"
  }

  workload_identity_config {
    identity_namespace = "${var.google_project}.svc.id.goog"
  }

}

resource "google_container_node_pool" "primary_preemptible_nodes" {
  provider = google-beta

  name     = "argocd-${terraform.workspace}-pool"
  location = var.google_zone
  project  = var.google_project
  cluster  = google_container_cluster.primary.name
  initial_node_count = 1

  autoscaling {
    min_node_count = 1
    max_node_count = 3
  }

  node_config {
    preemptible  = true
    machine_type = "e2-standard-2"

    metadata = {
      disable-legacy-endpoints = "true"
    }

    workload_metadata_config {
      node_metadata = "GKE_METADATA_SERVER"
    }

    oauth_scopes = [
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }
}
