{ config, lib, pkgs, ... }:
# Gitea NixOS module option definitions and configuration
# This module provides options and configuration for running a Gitea service.
# NEEDS TESTING
with lib;

# Reference to the Gitea service config
let
	cfg = config.services.gitea;
in {
	# Define options for the Gitea service
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

	# Apply configuration if Gitea is enabled
	config = mkIf cfg.enable {
		services.gitea = {
			enable = true; # Enable the Gitea service
			user = cfg.user; # User to run the service as
			group = cfg.group; # Group to run the service as
			domain = cfg.domain; # Domain for the Gitea instance
			httpPort = cfg.httpPort; # HTTP port for Gitea
			rootUrl = cfg.rootUrl; # Root URL for Gitea
		};
	};
}
