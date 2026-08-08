{ config, pkgs, lib, ... }:

{
    # SOPS configuration for builder SSH key (stored base64-encoded in the SOPS file)
    sops.secrets."gitea-runner-join-token" = {
        sopsFile = ./../../../secrets/hosts/core-vm-gitea-01.yml;
        owner = "root";
        group = "root";
        mode = "0600";
    };

    # Configures the Gitea Actions Runner service
    services.gitea-actions-runner.instances = {
        gitea-runner = {
            enable = true;
            # The URL of the Gitea instance to connect to
            url = "https://git.nepstad.it";
            # The name of the runner
            name = "gitea-runner";
            # The token used to register the runner (stored in SOPS)
            # Format needs to be like this, because the value is interpreted as a ENV file by the gitea-runner service: 
            # gitea-runner-join-token: TOKEN=asupersecretvalue
            tokenFile = config.sops.secrets."gitea-runner-join-token".path;
        };
    };


}
