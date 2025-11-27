{ config, ... } :

{
  # Environment variables
  environment.variables = rec {
    # Add scripts folder to path
    PATH = [ 
      "/home/henrik/.scripts" 
    ];
  };

}
