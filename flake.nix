{
  description = "A Nix flake for building the solar_analytics Rust project";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    rust-overlay.url = "github:oxalica/rust-overlay";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, rust-overlay, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        # Use a specific Rust version consistent with the previous Dockerfile if needed, or latest stable.
        # Check Cargo.toml for the MSRV if specified.
        rustChannel = pkgs.rust-bin.stable."latest".default; # Or specify a version like "1.85"

        overlays = [ (import rust-overlay) ];
        pkgs = import nixpkgs {
          inherit system overlays;
          config.allowUnfree = true; # If any dependencies require this
        };

        # Define supported target systems
        supportedSystems = [ "x86_64-linux" "aarch64-linux" ];

        # Build the Rust application
        buildApp = targetSystem: 
          let
            targetPkgs = import nixpkgs {
              system = system;
              overlays = [ (import rust-overlay) ];
              crossSystem = if targetSystem != system then { config = targetSystem; } else null;
            };
          in
          targetPkgs.rustPlatform.buildRustPackage {
            pname = "solar_analytics";
            version = "0.1.0";
            src = pkgs.lib.cleanSource ./.;
            cargoLock = { lockFile = ./Cargo.lock; };

            nativeBuildInputs = with targetPkgs; [ pkg-config ];
            buildInputs = with targetPkgs; [ openssl ];

            meta = with targetPkgs.lib; {
              description = "Solar Analytics Data Fetcher";
              license = licenses.mit;
            };
          };

        # Build for the host system
        solarAnalyticsApp = buildApp system;

        # Build for all supported systems
        multiArchBuild = pkgs.symlinkJoin {
          name = "solar_analytics-multiarch";
          paths = map buildApp supportedSystems;
        };

      in
      {
        packages = {
          default = solarAnalyticsApp;
          multiarch = multiArchBuild;
        };

        # Package for the Docker image build
        packages.dockerImage = pkgs.dockerTools.buildImage {
          name = "solar_analytics"; # Image name used internally and when loaded
          tag = "flake"; # Tag used internally and when loaded
          
          # Build a multi-platform image
          architecture = "all";

          # Base image contents (minimal)
          contents = [ 
            pkgs.cacert # For HTTPS calls (ca-certificates)
            pkgs.openssl # Runtime dependency (libssl3)
            multiArchBuild # The compiled application binary for multiple architectures
          ];

          config = {
            WorkingDir = "/app";
            User = "appuser";
            Env = [ "RUST_LOG=info" ];
            Cmd = [ "/bin/solar_analytics" ];
          };

          # Create the non-root user
          runAsRoot = ''
            ${pkgs.dockerTools.shadowSetup}
            groupadd -r appuser
            useradd -r -g appuser -d /app -m appuser 
            mkdir -p /app
            chown appuser:appuser /app
          '';
        };

        # Optional: Development shell
        devShells.default = pkgs.mkShell {
           nativeBuildInputs = with pkgs; [ pkg-config ];
           buildInputs = with pkgs; [ rustChannel rust-analyzer openssl ];
           RUST_SRC_PATH = "${pkgs.rustPlatform.rustLibSrc}";
        };
      });
}
