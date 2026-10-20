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

  # Serves SSH key items from Proton Pass. Needs a one-time `pass-cli login`,
  # then `systemctl --user start proton-pass-ssh-agent`.
  # pass-cli defaults to the kernel keyring, which this service can't read;
  # GNOME Keyring over D-Bus is reachable from both the shell and systemd.
  home.sessionVariables.PROTON_PASS_LINUX_KEYRING = "dbus";
  # For tools that ignore IdentityAgent, like git signing with ssh-keygen.
  home.sessionVariables.SSH_AUTH_SOCK = "\${XDG_RUNTIME_DIR}/proton-pass-agent.sock";
  # Only start once logged in: a failing agent force-logs-out, wiping the
  # session dir, and its restart loop used to break `pass-cli login` mid-way.
  systemd.user.services.proton-pass-ssh-agent = {
    Unit = {
      Description = "Proton Pass SSH agent";
      ConditionPathExists = "%h/.local/share/proton-pass-cli/.session/session.json";
    };
    Service = {
      Environment = "PROTON_PASS_LINUX_KEYRING=dbus";
      ExecStart = "${pkgs.proton-pass-cli}/bin/pass-cli ssh-agent start --socket-path %t/proton-pass-agent.sock";
      Restart = "on-failure";
      RestartSec = 30;
    };
    Install.WantedBy = [ "default.target" ];
  };
}
