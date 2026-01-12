{ config, lib, pkgs, ... }:
# NEEDS TESTING
with lib;

let
	cfg = config.services.gitea;
in {
	options.services.gitea = {
		enable = mkOption {
			type = types.bool;
			default = false;
			description = "Enable the Gitea service.";
		};
		user = mkOption {
			type = types.str;
			default = "gitea";
			description = "User to run the Gitea service as.";
		};
		group = mkOption {
			type = types.str;
			default = "gitea";
			description = "Group to run the Gitea service as.";
		};
		domain = mkOption {
			type = types.str;
			default = "localhost";
			description = "Domain for the Gitea instance.";
		};
		httpPort = mkOption {
			type = types.int;
			default = 3000;
			description = "HTTP port for Gitea.";
		};
		rootUrl = mkOption {
			type = types.str;
			default = "http://localhost:3000/";
			description = "Root URL for Gitea.";
		};
	};

	config = mkIf cfg.enable {
		services.gitea = {
			enable = true;
			user = cfg.user;
			group = cfg.group;
			domain = cfg.domain;
			httpPort = cfg.httpPort;
			rootUrl = cfg.rootUrl;
		};
	};
}
