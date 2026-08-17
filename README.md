# tf-tailscale-exit-node

Terraform config that launches a small Ubuntu VM in Oracle Cloud's London
region (`uk-london-1`) and configures it as a [Tailscale exit
node](https://tailscale.com/kb/1103/exit-nodes). Sized to fit inside
Oracle's Always Free tier, so it should cost $0/month.

Not critical infrastructure -- if it goes down, just re-run `terraform
apply`.

## Prerequisites

1. An Oracle Cloud account ([signup](https://signup.oraclecloud.com/)).
   Requires credit card verification even for the free tier; new accounts
   are occasionally flagged for manual review, so allow a day or two of
   slack before you need this running.
2. [Terraform](https://developer.hashicorp.com/terraform/install) >= 1.5.
3. An OCI API signing key. In the OCI console: **Profile icon > My profile
   > API keys > Add API key**. Generate a new key pair, download the
   private key, and save the config file snippet it shows you -- it has
   your `user_ocid`, `tenancy_ocid`, `fingerprint`, and `region`.
4. A [Tailscale](https://tailscale.com/) account.

## Setup

```bash
cp terraform.tfvars.example terraform.tfvars
# edit terraform.tfvars with the values from the API key step above
terraform init
terraform apply
```

If you left `tailscale_auth_key` blank, SSH in and bring Tailscale up
manually:

```bash
ssh ubuntu@$(terraform output -raw instance_public_ip)
sudo tailscale up --advertise-exit-node --ssh
```

Then approve the node as an exit node in the [admin
console](https://login.tailscale.com/admin/machines) (three-dot menu on
the machine -> "Edit route settings" -> enable "Use as exit node").
Auth-key-provisioned nodes still need this approval step unless the key
has exit-node routes pre-approved.

On any other device: `tailscale up --exit-node=<node-name>` (or pick it
from the Tailscale app's exit node menu).

## If Oracle capacity isn't available

The Always Free ARM shape (`VM.Standard.A1.Flex`) is subject to regional
capacity limits, and `uk-london-1` sometimes returns "Out of host
capacity" for it. Options if that happens:

- Retry -- capacity frees up periodically. Terraform will just fail the
  `apply`; there's nothing to clean up.
- Switch to the Always Free x86 shape instead, which doesn't have this
  problem: set `instance_shape = "VM.Standard.E2.1.Micro"` in
  `terraform.tfvars` and remove/ignore `instance_ocpus` and
  `instance_memory_in_gbs` (fixed shapes don't use `shape_config`, and the
  config already conditionalizes that block on the shape name).
- Fall back to AWS: a `t4g.micro` on Graviton in `eu-west-2` (London) or
  a Lightsail instance both run a few dollars a month and would need a
  near-identical cloud-init script (see `scripts/cloud-init.yaml.tpl`).

## Notes

- The Always Free tier for A1 (ARM) shapes was reduced in June 2026 from
  4 OCPU/24GB to 2 OCPU/12GB total across your tenancy. This config
  defaults to 1 OCPU/6GB, comfortably inside either limit.
- Oracle's stock Ubuntu image ships an iptables `INPUT` policy that only
  allows SSH by default; the cloud-init script opens the Tailscale UDP
  port (41641) so direct (non-relayed) connections work.
- State is local (`terraform.tfstate`) and gitignored. If you want this
  more durable, move to an OCI Object Storage backend.
