data "terraform_remote_state" "root" {
  backend = "local"

  config = {
    path = "../terraform.tfstate"
  }
}


resource "google_compute_instance" "instance" {
  name         = "migration-instance"
  machine_type = "e2-micro"
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
      size  = "10"
    }
  }

  network_interface {
    network = data.terraform_remote_state.root.outputs.vpc
    access_config {
      // Ephemeral public IP
    }
  }
  service_account {
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    scopes = ["cloud-platform"]
  }
  lifecycle {
    ignore_changes = [metadata["ssh-keys"]]
  }
}
