data "oci_identity_availability_domains" "this" {
  compartment_id = var.tenancy_ocid
}

data "oci_core_images" "ubuntu" {
  compartment_id           = var.compartment_id
  operating_system         = "Canonical Ubuntu"
  operating_system_version = "22.04"
  shape                    = var.instance_shape
  sort_by                  = "TIMECREATED"
  sort_order               = "DESC"
}

locals {
  availability_domain = data.oci_identity_availability_domains.this.availability_domains[var.availability_domain_number].name
  image_id            = data.oci_core_images.ubuntu.images[0].id
  is_flex_shape       = strcontains(var.instance_shape, "Flex")
}

resource "oci_core_instance" "exit_node" {
  compartment_id      = var.compartment_id
  availability_domain = local.availability_domain
  display_name        = var.instance_display_name
  shape               = var.instance_shape

  dynamic "shape_config" {
    for_each = local.is_flex_shape ? [1] : []
    content {
      ocpus         = var.instance_ocpus
      memory_in_gbs = var.instance_memory_in_gbs
    }
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.this.id
    assign_public_ip = true
  }

  source_details {
    source_type = "image"
    source_id   = local.image_id
  }

  metadata = {
    ssh_authorized_keys = file(var.ssh_public_key_path)
    user_data = base64encode(templatefile("${path.module}/scripts/cloud-init.yaml.tpl", {
      tailscale_auth_key = var.tailscale_auth_key
    }))
  }
}
