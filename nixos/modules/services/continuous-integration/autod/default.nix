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

      containerConfig = mkOption {
        default = {};
        description = 
          ''
          This is used to create the container entry. See
          <option>containers</option>
          '';
      };

      backup = mkOption {
        type = types.nullOr types.path;
        default = null;
        description =
          ''
          The path to a backup directory on the host.
          If enabled and a "backup" executable is found in .nix/bin, then 
          the host will periodically call: ./nix/bin/backup path
          to initiate backup. The script should copy all state to the given dir.
          This script does not run in the container, it runs on the host, so
          should only be enabled for trusted containers.
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

    services.autodeploy.poll = mkOption {
      type = types.str;
      default = "1min";
      description = 
        ''
        Set the time period for polling application repositories
        for changes.
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

    services.autodeploy.notify = mkOption {
      type = types.str;
      example = "jeff@example.com";
      description = 
        ''
        Email address to send notifications of success/failure
        to.
        '';
    };


  };


  ###### implementation

  config = mkIf cfg.enable (let
    conf = pkgs.writeText "autodeploy.conf" (builtins.toJSON cfg.apps);
  in {

    # poll each repository for changes

    systemd.timers.autodeploy = {
      description = "timer that triggers autodeployment";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnBootSec = "5min";
        OnUnitInactiveSec = cfg.poll;
        Unit = "autodeploy.service";
      };
    };

    systemd.services.autodeploy = { 
      description = "continuous deployment";
      path = [ pkgs.git pkgs.autod pkgs.openssh pkgs.ssmtp ];
      restartTriggers = [ conf ];
      environment = {
        NIX_PATH = "nixos=/etc/nixos/nixpkgs/nixos/:nixpkgs=/etc/nixos/nixpkgs:nixos-config=/etc/nixos/configuration.nix";
      };
      script = 
        ''
        export PATH="/run/current-system/sw/bin/:/run/current-system/sw/sbin/:$PATH"
        export HOME="/root"
        ${pkgs.autod}/bin/autod \
          -c ${conf} \
          -s /var/autod \
          -o /etc/nixos/containers.nix \
          -to ${cfg.notify} \
          -from web@cycleapp.com \
          -host ${config.networking.defaultMailServer.hostName} \
          -user ${config.networking.defaultMailServer.authUser} \
          -pass ${config.networking.defaultMailServer.authPass}
        '';
      serviceConfig = {
        Type = "oneshot";
      };
    };

    # backups

    systemd.timers.autobackup = {
      description = "timer that triggers backups";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnBootSec = "12h";
        OnUnitInactiveSec = "12h";
        Unit = "autobackup.service";
      };
    };

    systemd.services.autobackup = { 
      description = "automatic backups";
      path = [ 
        pkgs.git 
        pkgs.openssh 
        pkgs.rsync 
        pkgs.ssmtp 
        pkgs.bash
      ];
      environment = {
        HOME = /root;
      };
      script = concatStringsSep " " (map (app: ''

        script=/var/autod/containers/${app}/repo/.nix/bin/backup
        if [[ -x "$script" ]]; then 
          path=${(getAttr app cfg.apps).backup}
          if [[ -e "$path" ]]; then
            $script $path
          fi
        fi

      '') (attrNames (filterAttrs (n: v: v.backup != null) cfg.apps)));
      serviceConfig = {
        Type = "oneshot";
      };
    };

  });

}
