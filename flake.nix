{
  description = "tfenv-rs";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    flake-utils.url = "github:numtide/flake-utils";
    flake-utils.inputs.nixpkgs.follows = "nixpkgs";

    rust-overlay.url = "github:oxalica/rust-overlay";
    rust-overlay.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, flake-utils, rust-overlay, ... }@inputs:
    flake-utils.lib.eachDefaultSystem (system:
      let
        overlays = [ (import rust-overlay) ];
        pkgs = import nixpkgs {
          inherit system overlays;
        };
        avrlibc = pkgs.pkgsCross.avr.libcCross;

      in
      rec {
        # `nix develop`
        devShell = pkgs.mkShell
          {
            buildInputs = with pkgs; [
              cargo-generate

              (rust-bin.nightly."2021-01-07".default.override {
                extensions = [ "rust-src" ];
              })
              rust-analyzer

              pkgsCross.avr.buildPackages.binutils
              pkgsCross.avr.buildPackages.gcc8
              avrlibc
              avrdude
            ] ++ lib.optionals stdenv.isDarwin (with darwin.apple_sdk.frameworks; [
              libiconv
              CoreServices
            ]);

            AVR_CPU_FREQUENCY_HZ = 16000000;
            # AVR_CFLAGS = avr_incflags;
            # AVR_ASFLAGS = avr_incflags;
            RUST_BACKTRACE = 1;

            shellHook = ''
              export PATH=$PATH:$HOME/.cargo/bin
            '';
          };
      }
    );
}

