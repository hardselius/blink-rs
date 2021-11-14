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
        overlays = [
          (import rust-overlay)
        ];
        pkgs = import nixpkgs {
          inherit system overlays;
        };
        avrlibc = pkgs.pkgsCross.avr.libcCross;
        avr_incflags = [
          "-isystem ${avrlibc}/avr/include"
          "-B${avrlibc}/avr/lib/avr5"
          "-L${avrlibc}/avr/lib/avr5"
          "-B${avrlibc}/avr/lib/avr35"
          "-L${avrlibc}/avr/lib/avr35"
          "-B${avrlibc}/avr/lib/avr51"
          "-L${avrlibc}/avr/lib/avr51"
        ];
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

              pkgsCross.avr.buildPackages.binutils # TODO: avr-ld cannot find -liconv
              pkgsCross.avr.buildPackages.gcc11
              avrlibc
              avrdude
            ] ++ lib.optionals stdenv.isDarwin (with darwin.apple_sdk.frameworks; [
              libiconv
              CoreServices
            ]);

            AVR_CPU_FREQUENCY_HZ = 16000000;
            AVR_CFLAGS = avr_incflags;
            AVR_ASFLAGS = avr_incflags;
            RUST_BACKTRACE = 1;

            shellHook = ''
              # Prevent the avr-gcc wrapper from picking up host GCC flags like
              # -iframework, which is problematic on Darwin
              unset NIX_CFLAGS_COMPILE_FOR_TARGET
              export PATH=$PATH:$HOME/.cargo/bin
            '';
          };
      }
    );
}

