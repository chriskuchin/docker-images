{ pkgs ? import <nixpkgs> {} }:
  pkgs.mkShell {
    # nativeBuildInputs is usually what you want -- tools you need to run
    nativeBuildInputs = with pkgs.buildPackages; [
      git
      nomad
    ];

    NOMAD_ADDR=https://n.home.cksuperman.com;
}