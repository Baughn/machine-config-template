{ config
, lib
, ...
}:
let
  secrets = {
    # Example:
    # "grafana-admin-password" = {
    #   file = ./grafana-admin-password.age;
    #   hosts = [ "tsugumi" ];
    #   owner = "grafana";
    #   mode = "0400";
    # };
  };
in
{
  age.secrets = lib.filterAttrs
    (name: value: value != null)
    (lib.mapAttrs
      (name: value:
        if value ? hosts then
          if builtins.elem config.networking.hostName value.hosts then
            builtins.removeAttrs value [ "hosts" ]
          else
            null
        else
          value
      )
      secrets);
}
