{
  # =========================
  # User and authentication variables for NixOS configuration
  # =========================

  # Full name of the primary user
  fullName = "Henrik Xavier Nepstad";

  # Username for login
  userName = "henrik";

  # Email address for user configuration (e.g., git)
  userEmail = "mail@topheinz.com";

  # Default password hash for new machines
  # Generate with: mkpasswd -m sha-512
  hashedPassword = "$6$tsKkFmzTKdHpfz/S$84YR0GJWGYVk3rGeKPSdeX.YaFyZV8V7PUWQLzrZvoo0CAt2WwuxyjQwCLOBx.BRecJsoAxKU9w6wF04Z57FY."; 

  # SSH public keys for user authentication
  sshPublicKeyPersonal = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHlcSbSiViVlhO3v2jz7U0NYBi8hags7R0TCvhIFSlgA"; # Portunus-Alfa
  sshPublicKeyWork = ""; # No work key (yet)
}