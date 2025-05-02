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
        overlays = [ (import rust-overlay) ];
        pkgs = import nixpkgs {
          inherit system overlays;
          config.allowUnfree = true;
        };
        
        rustChannel = pkgs.rust-bin.stable."latest".default;

        # Single architecture build for the host system
        solarAnalyticsApp = pkgs.rustPlatform.buildRustPackage {
          pname = "solar_analytics";
          version = "0.1.0";
          src = pkgs.lib.cleanSource ./.;
          cargoLock = { lockFile = ./Cargo.lock; };

          nativeBuildInputs = with pkgs; [ pkg-config ];
          buildInputs = with pkgs; [ openssl ];

          meta = with pkgs.lib; {
            description = "Solar Analytics Data Fetcher";
            license = licenses.mit;
          };
        };

        # Create a Dockerfile template that will be used by Docker buildx
        dockerfileTemplate = pkgs.writeTextFile {
          name = "Dockerfile.template";
          text = ''
            FROM scratch
            
            # Add SSL certificates for HTTPS
            COPY --from=alpine:latest /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
            
            # Add OpenSSL libraries - using a minimal base image approach
            COPY --from=alpine:latest /usr/lib/libssl.so* /usr/lib/
            COPY --from=alpine:latest /usr/lib/libcrypto.so* /usr/lib/
            
            # Create a non-root user
            RUN addgroup -S appuser && adduser -S -G appuser -h /app appuser
            
            # Copy the application binary - this will be replaced with the arch-specific binary
            COPY ./solar_analytics /bin/solar_analytics
            
            WORKDIR /app
            USER appuser
            ENV RUST_LOG=info
            
            CMD ["/bin/solar_analytics"]
          '';
        };

      in
      {
        packages = {
          default = solarAnalyticsApp;
          
          # Export the compiled binary for the current platform
          binary = solarAnalyticsApp;
          
          # Export the Dockerfile template
          dockerfileTemplate = dockerfileTemplate;
        };

        # Development shell
        devShells.default = pkgs.mkShell {
          nativeBuildInputs = with pkgs; [ pkg-config ];
          buildInputs = with pkgs; [ rustChannel rust-analyzer openssl ];
          RUST_SRC_PATH = "${pkgs.rustPlatform.rustLibSrc}";
        };
      });
}
