with import <nixpkgs> {};
with lib;

{ stdenv,
  fetchurl,
  unzip,
  nodejs,
  elixir,
  mysql,
  makeWrapper,
  mysql_host,
  mysql_username,
  mysql_password,
  mysql_database,
  secret_key,
  extraElixirConfig ? "" }:

stdenv.mkDerivation {
  name = "danmaku";

  builder = builtins.toFile "builder.sh" ''
source $stdenv/setup;
export MIX_ENV=prod
export HOME=$(pwd)/fake-home
mkdir fake-home
unzip $src
mv danmaku-2085d27aefe985ce3fc5e7baa35766aa056ff4e6/* .
rm -rf danmaku-2085d27aefe985ce3fc5e7baa35766aa056ff4e6
ls -lah
pwd
echo -e "$elixirConfig" > config/prod.secret.exs
echo -e "$extraElixirConfig" >> config/prod.secret.exs
mix local.hex --force
mix deps.get
npm install
npm run brunch
mix local.rebar
mix phoenix.digest
mix compile
mix release

mkdir -p $out
mv ./* $out
cd $out

ln -s $out/rel/danmaku_api/bin bin

cat <<- EOF > rel/danmaku_api/bin/migrate_and_start.sh
#!/usr/bin/env bash
export MIX_ENV=prod
export HOME=$out/fake-home
cd $out
mix ecto.migrate -r DanmakuApi.Repo
bin/danmaku_api foreground
EOF
chmod +x rel/danmaku_api/bin/migrate_and_start.sh

wrapProgram $out/bin/migrate_and_start.sh \
  --suffix PATH : "$elixir/bin:$procps/bin:$gawk/bin:$utillinux/bin:$bash/bin" \
  --suffix HOME : "$out/fake-home"

  '';

  elixirConfig = ''
    use Mix.Config

    config :danmaku_api, ecto_repos: []

    config :danmaku_api, DanmakuApi.Endpoint,
      secret_key_base: "${secret_key}"

    config :danmaku_api, DanmakuApi.Repo,
      adapter: Ecto.Adapters.MySQL,
      username: "${mysql_username}",
      password: "${mysql_password}",
      database: "${mysql_database}",
      hostname: "${mysql_host}",
      pool_size: 20
  '';

  elixir = elixir;
  procps = procps;
  gawk = gawk;
  utillinux = utillinux;
  bash = bash;

  # Customizable development requirements
  buildInputs = [
    # Add packages from nix-env -qaP | grep -i needle queries
    unzip
    nodejs
    elixir
    mysql
    makeWrapper

    # erlang runtime
    procps
    gawk
    utillinux
    bash
  ];

  src = fetchurl {
    url = https://github.com/b123400/danmaku/archive/2085d27aefe985ce3fc5e7baa35766aa056ff4e6.zip;
    md5 = "746e22a0b74df88779c1afada0411277";
  };

  # Customizable development shell setup with at last SSL certs set
  shellHook = ''
    # export SSL_CERT_FILE=${cacert}/etc/ssl/certs/ca-bundle.crt
  '';
}
