{
  inputs = {
    nixpkgs.url = "git+https://github.com/NixOS/nixpkgs?shallow=1&ref=nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";
    hercules-ci-effects.url = "github:hercules-ci/hercules-ci-effects";
    hercules-ci-effects.inputs.nixpkgs.follows = "nixpkgs";
    hercules-ci-effects.inputs.flake-parts.follows = "flake-parts";
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } (
      {
        withSystem,
        self,
        config,
        ...
      }:
      {
        imports = [
          inputs.hercules-ci-effects.flakeModule
        ];
        systems = [
          "x86_64-linux"
          "aarch64-darwin"
        ];

        herculesCI = herculesCI: {
          onPush.default.outputs.effects.deploy-main = withSystem config.defaultEffectSystem (
            { pkgs, hci-effects, ... }:
            hci-effects.runIf (herculesCI.config.repo.branch == "main") (
              hci-effects.mkEffect {
                effectScript = ''
                  echo "${builtins.toJSON { inherit (herculesCI.config.repo) branch tag rev; }}"
                  ${pkgs.hello}/bin/hello
                '';
              }
            )
          );
          onPush.default.outputs.effects.deploy-master = withSystem config.defaultEffectSystem (
            { pkgs, hci-effects, ... }:
            hci-effects.runIf (herculesCI.config.repo.branch == "master") (
              hci-effects.mkEffect {
                effectScript = ''
                  echo "${builtins.toJSON { inherit (herculesCI.config.repo) branch tag rev; }}"
                  ${pkgs.hello}/bin/hello
                '';
              }
            )
          );
          onPush.default.outputs.effects.true = withSystem config.defaultEffectSystem (
            { pkgs, hci-effects, ... }:
            hci-effects.runIf (true) (
              hci-effects.mkEffect {
                effectScript = ''
                  echo "${builtins.toJSON { inherit (herculesCI.config.repo) branch tag rev; }}"
                  ${pkgs.hello}/bin/hello
                '';
              }
            )
          );
          onPush.default.outputs.effects.always = withSystem config.defaultEffectSystem (
            { pkgs, hci-effects, ... }:
            hci-effects.mkEffect {
              effectScript = ''
                echo "${builtins.toJSON { inherit (herculesCI.config.repo) branch tag rev; }}"
                ${pkgs.hello}/bin/hello
              '';
            }
          );
        };

      }
    );
}
