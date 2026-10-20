{ pkgs, ... }:
let
  ethUser = "nogerber";
in
{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    settings = {
      "*".IdentityAgent = "\${XDG_RUNTIME_DIR}/proton-pass-agent.sock";

      "jumphost.inf.ethz.ch".User = ethUser;

      "*.ethz.ch !jumphost.inf.ethz.ch" = {
        User = ethUser;
        ProxyJump = "jumphost.inf.ethz.ch";
      };
    };
  };

  # Serves SSH key items from Proton Pass. Needs a one-time `pass-cli login`;
  # until then it fails and keeps retrying.
  systemd.user.services.proton-pass-ssh-agent = {
    Unit.Description = "Proton Pass SSH agent";
    Service = {
      ExecStart = "${pkgs.proton-pass-cli}/bin/pass-cli ssh-agent start --socket-path %t/proton-pass-agent.sock";
      Restart = "on-failure";
      RestartSec = 30;
    };
    Install.WantedBy = [ "default.target" ];
  };
}
