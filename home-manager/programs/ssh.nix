{ ... }:
let
  ethUser = "nogerber";
in
{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    matchBlocks = {
      "*".identityAgent = "~/.1password/agent.sock";

      "jumphost.inf.ethz.ch".user = ethUser;

      "ethz" = {
        host = "*.ethz.ch !jumphost.inf.ethz.ch";
        user = ethUser;
        proxyJump = "jumphost.inf.ethz.ch";
      };
    };
  };
}
