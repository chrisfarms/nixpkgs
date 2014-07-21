{ config, lib, pkgs, ... }:

with lib;

let

  cfg = config.services.autodeploy;

  appOptions = { 
    options = {
    
      url = mkOption {
        type = types.str;
        example = "git@bitbucket.org:yourname/yourrepo.git";
        description = 
          ''
          Repository URL for the project. The repository should
          contain a configuration.nix and shell.nix that can build
          the container and environment respectfully.
          '';
      };

      branch = mkOption {
        type = types.str;
        example = "staging";
        default = "master";
        description =
          ''
          The name of the branch to use.
          '';
      };

      key = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = 
          ''
          SSH key that can pull from the repository
          '';
      };

      notify = mkOption {
        type = types.listOf types.str;
        default = [];
        example = [ "jeff@example.com" ];
        description = 
          ''
          List of email addresses that notifications will be 
          sent to after building/deploying/etc.
          '';
      };

      containerConfig = mkOption {
        default = {};
        description = 
          ''
          This is used to create the container entry. See
          <option>containers</option>
          '';
      };

    };
  };

in

{

  ###### interface

  options = {
    
    services.autodeploy.enable = mkOption {
      type = types.bool;
      default = false;
      description = 
        ''
        Enable continuous deployment of applications specified
        in <option>services.autodeployment.apps</option>
        '';
    };

    services.autodeploy.extraConfig = mkOption {
      default = {};
      description = 
        ''
        This is merged into ALL container configurations.
        Use this to setup global container options such as
        networking, nameservers etc.
        '';
    };
    
    services.autodeploy.apps = mkOption {
      default = {};
      type = types.attrsOf (types.submodule appOptions);
      description = 
        ''
        Set of project definitions that will be deployed
        as containers.
        '';
    };

  };


  ###### implementation

  config = let
    
    conf = pkgs.writeText "autodeploy.conf" (builtins.toJSON cfg.apps);

  in {

    systemd.timers.autodeploy = {
      description = "timer that triggers autodeployment";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnBootSec = "3min";
        OnUnitInactiveSec = "3min";
        Unit = "autodeploy.service";
      };
    };

    systemd.services.autodeploy = { 
      description = "continuous deployment";
      path = [ pkgs.git pkgs.autod pkgs.openssh ];
      restartTriggers = [ conf ];
      environment = {
        NIX_PATH = "nixos=/etc/nixos/nixpkgs/nixos/:nixpkgs=/etc/nixos/nixpkgs:nixos-config=/etc/nixos/configuration.nix";
      };
      script = 
        ''
        export PATH="/run/current-system/sw/bin/:$PATH"
        export HOME="/root"
        ${pkgs.autod}/bin/autod -c ${conf} -s /var/autod -o /etc/nixos/containers.nix
        echo "DEPLOYMENT COMPLETE"
        '';
      serviceConfig = {
        Type = "oneshot";
      };
    };

  };

}
