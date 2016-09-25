let
  pkgs = import <nixpkgs> {};
  stdenv = pkgs.stdenv;
  fetchurl = pkgs.fetchurl;
  unzip = pkgs.unzip;
  nodejs = pkgs.nodejs-5_x;
  elixir = pkgs.elixir;
  mysql = pkgs.mysql51;
  makeWrapper = pkgs.makeWrapper;

  danmaku = import ./danmaku.nix {
    inherit stdenv fetchurl unzip nodejs elixir makeWrapper mysql;

    mysql_host = "127.0.0.1";
    mysql_username = "root";
    mysql_password = "";
    mysql_database = "danmaku_api_dev";
    secret_key = "";
  };

  dataDir = "/var/danmaku";
in {

  networking.firewall.allowedTCPPorts = [ 9999 ];
  networking.firewall.allowPing = true;

  systemd.services.danmaku = {
    wantedBy = [ "multi-user.target" ];
    after = [ "mysql.service" ];
    environment = {
      PORT = "9999";
      RELEASE_MUTABLE_DIR = dataDir;
      HOME = dataDir;
    };
    serviceConfig = {
      Type = "simple";
      ExecStart = ''
        ${danmaku}/bin/danmaku_api foreground
      '';
      ExecStop = ''
        ${danmaku}/bin/danmaku_api stop
      '';
      User = "root";
    };
    path = [pkgs.procps pkgs.gawk pkgs.utillinux];
  };
}
