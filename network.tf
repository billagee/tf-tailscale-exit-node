resource "oci_core_vcn" "this" {
  compartment_id = var.compartment_id
  cidr_blocks    = ["10.0.0.0/16"]
  display_name   = "${var.instance_display_name}-vcn"
  dns_label      = "tsexitnode"
}

resource "oci_core_internet_gateway" "this" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.this.id
  display_name   = "${var.instance_display_name}-igw"
  enabled        = true
}

resource "oci_core_route_table" "this" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.this.id
  display_name   = "${var.instance_display_name}-rt"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.this.id
  }
}

resource "oci_core_security_list" "this" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.this.id
  display_name   = "${var.instance_display_name}-seclist"

  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
  }

  # SSH for management.
  ingress_security_rules {
    source   = var.ssh_allowed_cidr
    protocol = "6" # TCP
    tcp_options {
      min = 22
      max = 22
    }
  }

  # Tailscale's direct (non-relayed) WireGuard-based transport.
  ingress_security_rules {
    source   = "0.0.0.0/0"
    protocol = "17" # UDP
    udp_options {
      min = 41641
      max = 41641
    }
  }
}

resource "oci_core_subnet" "this" {
  compartment_id             = var.compartment_id
  vcn_id                     = oci_core_vcn.this.id
  cidr_block                 = "10.0.1.0/24"
  display_name               = "${var.instance_display_name}-subnet"
  dns_label                  = "tsexitnodesub"
  route_table_id             = oci_core_route_table.this.id
  security_list_ids          = [oci_core_security_list.this.id]
  prohibit_public_ip_on_vnic = false
}
