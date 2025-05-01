{
  description = "Solar Analytics - A Rust application for solar power analytics";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
      };
    };
  };

  outputs = { self, nixpkgs, flake-utils, rust-overlay }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        overlays = [ (import rust-overlay) ];
        pkgs = import nixpkgs {
          inherit system overlays;
        };
        
        rustVersion = pkgs.rust-bin.stable.latest.default;
        
        nativeBuildInputs = with pkgs; [
          rustVersion
          pkg-config
        ];
        
        buildInputs = with pkgs; [
          openssl
        ];
        
        runtimeDependencies = with pkgs; [
          openssl
        ];
      in
      {
        packages.default = pkgs.rustPlatform.buildRustPackage {
          pname = "solar_analytics";
          version = "0.1.0";
          src = ./.;
          
          inherit nativeBuildInputs buildInputs;
          
          cargoLock = {
            lockFile = ./Cargo.lock;
          };
          
          # Enable better error messages from the Rust compiler
          RUST_BACKTRACE = 1;
          
          # Set default logging level
          RUST_LOG = "info";
        };
        
        apps.default = flake-utils.lib.mkApp {
          drv = self.packages.${system}.default;
        };
        
        devShells.default = pkgs.mkShell {
          inherit nativeBuildInputs buildInputs;
          
          RUST_BACKTRACE = 1;
          RUST_LOG = "info";
          
          shellHook = ''
            echo "Solar Analytics development environment"
            echo "Rust version: $(rustc --version)"
          '';
        };
      }
    );
}