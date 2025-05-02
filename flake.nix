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

        # Build the Rust application
        solarAnalyticsApp = pkgs.rustPlatform.buildRustPackage {
          pname = "solar_analytics";
          # Consider fetching version from Cargo.toml dynamically if needed
          version = "0.1.0";

          src = pkgs.lib.cleanSource ./.;

          cargoLock = {
            lockFile = ./Cargo.lock;
          };

          # Ensure build dependencies match those previously installed via apt-get
          nativeBuildInputs = with pkgs; [
            pkg-config
          ];
          buildInputs = with pkgs; [
            openssl # Corresponds to libssl-dev
          ];

          # If your application needs runtime dependencies beyond libc/libgcc,
          # they might need to be handled differently, potentially by adjusting the final Docker image.

          meta = with pkgs.lib; {
            description = "Solar Analytics Data Fetcher";
            # homepage = "https://github.com/your-repo/solar_analytics";
            license = licenses.mit; # Update if different
            # maintainers = with maintainers; [ your-github-handle ];
          };
        };

      in
      {
        packages.default = solarAnalyticsApp;

        # Package for the Docker image build
        packages.dockerImage = pkgs.dockerTools.buildImage {
          name = "solar_analytics"; # Image name used internally and when loaded
          tag = "flake"; # Tag used internally and when loaded

          # Base image contents (minimal)
          contents = [ 
            pkgs.cacert # For HTTPS calls (ca-certificates)
            pkgs.openssl # Runtime dependency (libssl3)
            solarAnalyticsApp # The compiled application binary
          ];

          config = {
            # Match runtime environment from original Dockerfile
            WorkingDir = "/app"; # Optional: Set a working directory
            User = "appuser"; # Run as non-root user
            Env = [ 
              "RUST_LOG=info" 
              # Other ENV vars should be set via docker run or docker-compose
            ]; 
            Cmd = [ "${solarAnalyticsApp}/bin/solar_analytics" ]; # Command to run
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
           nativeBuildInputs = with pkgs; [
            pkg-config
          ];
          buildInputs = with pkgs; [
            rustChannel
            rust-analyzer
            openssl # Runtime dependency for local testing
          ];
          RUST_SRC_PATH = "${pkgs.rustPlatform.rustLibSrc}";
        };
      });
}
