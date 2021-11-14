(import
  (
    let
      lock = builtins.fromJSON (builtins.readFile ./flake.lock);
    in
    fetchTarball {
      url = "https://github.com/edolstra/flake-compat/archive/${lock.nodes.flake-compat.locked.rev}.tar.gz";
      sha256 = lock.nodes.flake-compat.locked.narHash;
    }
  )
  {
    src = ./.;
  }).shellNix

# let
#   rustOverlay = import (builtins.fetchTarball "https://github.com/oxalica/rust-overlay/archive/master.tar.gz");
#   nixpkgs = import (builtins.fetchTarball "https://github.com/NixOS/nixpkgs/archive/nixpkgs-unstable.tar.gz") {
#     overlays = [ rustOverlay ];
#   };

#   avrlibc = nixpkgs.pkgsCross.avr.libcCross;

#   inherit (nixpkgs.lib) optionals;
# in
# with nixpkgs;
# mkShell rec {
#   buildInputs = [
#     rust-bin.nightly.latest.default
#     rust-analyzer

#     pkgsCross.avr.buildPackages.binutils
#     # pkgsCross.avr.buildPackages.gcc8
#     avrlibc
#     avrdude
#   ]
#   ++ optionals stdenv.isDarwin (with darwin.apple_sdk.frameworks; [
#     libiconv
#     CoreServices
#   ]);

#   RUST_BACKTRACE = 1;

#   shellHook = ''
#     export PATH=$PATH:$HOME/.cargo/bin
#   '';
# }
