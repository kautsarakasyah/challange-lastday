provider "google" {
  credentials = file("~/.gcp/key.json")
  project     = "rakamin-ttc-odp-it-2"
  region      = "asia-southeast2"
}

resource "google_cloud_run_service" "default" {
  name     = "challange-lastday"
  location = "asia-southeast2"

  template {
    spec {
      containers {
        image = "docker.io/kautsarakasyah/challange-lastday:latest"
        ports {
          container_port = 8080
        }
      }
    }
  }

  traffics {
    percent         = 100
    latest_revision = true
  }
}

resource "google_cloud_run_service_iam_member" "invoker" {
  location        = google_cloud_run_service.default.location
  service         = google_cloud_run_service.default.name
  role            = "roles/run.invoker"
  member          = "allUsers"
}
