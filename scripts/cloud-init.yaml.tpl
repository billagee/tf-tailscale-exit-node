#cloud-config
package_update: true

runcmd:
  # Install Tailscale.
  - curl -fsSL https://tailscale.com/install.sh | sh

  # Allow this box to route traffic for other tailnet devices.
  - sysctl -w net.ipv4.ip_forward=1
  - sysctl -w net.ipv6.conf.all.forwarding=1
  - echo 'net.ipv4.ip_forward=1' >> /etc/sysctl.d/99-tailscale.conf
  - echo 'net.ipv6.conf.all.forwarding=1' >> /etc/sysctl.d/99-tailscale.conf
  - sysctl -p /etc/sysctl.d/99-tailscale.conf

  # Oracle's stock Ubuntu image ships an iptables INPUT policy that only
  # allows SSH; open the Tailscale UDP port so direct connections work.
  - iptables -I INPUT -p udp --dport 41641 -j ACCEPT
  - netfilter-persistent save

%{ if tailscale_auth_key != "" ~}
  - tailscale up --auth-key=${tailscale_auth_key} --advertise-exit-node --ssh
%{ else ~}
  # No auth key was supplied. SSH in and run:
  #   sudo tailscale up --advertise-exit-node --ssh
  # then approve the exit node in https://login.tailscale.com/admin/machines
%{ endif ~}
