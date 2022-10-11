{
  # https://github.com/mickael-kerjean/filestash/blob/master/docker/Dockerfile
  description = "Filestash -- a self-hostable web file manager frontend for any backend";

  inputs.nixpkgs.url = github:NixOS/nixpkgs/nixos-22.05;

  inputs.flake-compat = {
    url = "github:edolstra/flake-compat";
    flake = false;
  };

  outputs = { self, nixpkgs }: {
    defaultPackage.x86_64-linux = import ./package self { inherit nixpkgs; };

    moduleOptions = {
      enable = with nixpkgs; mkOption {
        description = "Enable the Filestash service";
	type = types.bool;
	default = false;
      };
    };

    nixosModules.default =
    	{ config, ... }:
	let cfg = config.services.filestash;
	in {
	  options.services.filestash = self.moduleOptions;
	  config = {
	    users.users.filestash.isSystemUser = true;
	    systemd.services.filestash = {
	      description = "Filestash";
	      wantedBy = [ "multi-user.target" ];
	      after = [ "network.target" ];
	      serviceConfig = {
	        ExecStart = "${self.defaultPackage.x86_64-linux}/bin/filestash";
		PrivateTmp = true;
		PrivateDevices = true;
		ProtectHome = "read-only";
		ProtectSystem = "full";
		StateDirectory = "filestash";
		ReadWritePaths = [ "/var/lib/filestash" ];
		BindPaths = [ "/var/lib/filestash:/app/data/state" ];
		WorkingDirectory = "/app";
	      };
	    };

	    networking.firewall.allowedTCPPorts = [ 8334 ];
	  };
	};
  };
}
