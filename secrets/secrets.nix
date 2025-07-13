let
  username_here = [
    # Example only. You need to create an SSH public key for this to work.
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGs877ZtpIoKuc+Jn+GDISMBWxxGyZNdubdnqX2b6TV0" # Saya
  ];
  users = [ username_here ];

  # Machine host keys.
  # The real host key can be found with `ssh-keyscan hostname | grep ssh-ed25519`. Note that the hostname itself should not be included.
  example_host = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO9z421G7kH33uethHVKCXs1FcPPdxJQarKIZIZAx4MN";
  systems = [ example_host ];

  all = users ++ systems;
  host = h: [ h ];
in
{
  # Example secret
  # "grafana-admin-password.age".publicKeys = host tsugumi;
}
