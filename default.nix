with import <nixpkgs> {};
stdenv.mkDerivation rec {
  name = "env";

  # Mandatory boilerplate for buildable env
  env = buildEnv { name = name; paths = buildInputs; };
  # builder = builtins.toFile "builder.sh" ''
  #   source $stdenv/setup; ln -s $env $out
  # '';

  # Customizable development requirements
  buildInputs = [
    # Add packages from nix-env -qaP | grep -i needle queries
    nodejs-5_x
    elixir
    mysql51
  ];

  # Customizable development shell setup with at last SSL certs set
  shellHook = ''
    # export SSL_CERT_FILE=${cacert}/etc/ssl/certs/ca-bundle.crt
  '';
}