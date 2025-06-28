{
  description = "Claude Squad - AI-Powered Git Workflows";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        
        claude-squad = pkgs.buildGoModule rec {
          pname = "claude-squad";
          version = "0.1.0";
          
          src = ./.;
          
          vendorHash = "sha256-BduH6Vu+p5iFe1N5svZRsb9QuFlhf7usBjMsOtRn2nQ=";
          
          ldflags = [
            "-s"
            "-w"
            "-X main.version=${version}"
          ];
          
          nativeBuildInputs = [ pkgs.makeWrapper ];
          
          # The binary is named claude-squad in the build
          postInstall = ''
            # Rename to cs as per the install script default
            mv $out/bin/claude-squad $out/bin/cs
            
            # Wrap the binary with tmux and gh in PATH
            wrapProgram $out/bin/cs \
              --prefix PATH : ${pkgs.lib.makeBinPath [ pkgs.tmux pkgs.gh ]}
          '';
          
          meta = with pkgs.lib; {
            description = "AI-Powered Git Workflows";
            homepage = "https://github.com/getmissionctrl/claude-squad";
            license = licenses.mit;
            maintainers = [ ];
            mainProgram = "cs";
          };
        };
      in
      {
        packages = {
          default = claude-squad;
          claude-squad = claude-squad;
        };
        
        apps.default = {
          type = "app";
          program = "${claude-squad}/bin/cs";
        };
        
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            go
            tmux
            gh
            # Development tools
            gopls
            gotools
            go-tools
          ];
        };
      });
}