{ ... }:
let
  ethUser = "nogerber";
in
{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    settings = {
      "*".IdentityAgent = "~/.1password/agent.sock";

      "jumphost.inf.ethz.ch".User = ethUser;

      "*.ethz.ch !jumphost.inf.ethz.ch" = {
        User = ethUser;
        ProxyJump = "jumphost.inf.ethz.ch";
      };
    };
  };
}
