{
  description = "ZMK keyboard configs, built with nix";

  inputs = {
    # zephyr 3.5 build scripts predate python 3.14's pkg_resources removal
    # in unstable's setuptools - keep this on stable
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";

    zmk-nix = {
      url = "github:lilyinstarlight/zmk-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      zmk-nix,
    }:
    let
      lib = nixpkgs.lib;
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      forAllSystems = lib.genAttrs systems;
      registry = import ./keyboards.nix;
    in
    {
      flakeModules.default = import ./nix/module.nix;

      packages = forAllSystems (
        system:
        let
          keyboards = lib.foldl' lib.recursiveUpdate { } (
            lib.mapAttrsToList (
              name: kb:
              let
                firmware = zmk-nix.legacyPackages.${system}.buildSplitKeyboard (
                  (lib.filterAttrs (n: _: n != "patches") kb)
                  // {
                    inherit name;
                    # keyboards/ is the west workspace root; each keyboard dir is
                    # the ZMK_CONFIG dir and carries its own west.yml
                    src = lib.sourceFilesBySuffices "${self}/keyboards" [
                      ".conf"
                      ".keymap"
                      ".yml"
                    ];
                    config = name;
                    # patches apply to the fetched zmk-nice-oled module after
                    # configure - plain `patches =` runs before west fetches it
                    postConfigure = lib.optionalString ((kb.patches or [ ]) != [ ]) ''
                      git -C ../zmk-nice-oled apply ${toString (map (p: "${self}/${p}") kb.patches)}
                    '';
                  }
                );
              in
              {
                ${name} = firmware;
                "flash-${name}" =
                  (zmk-nix.packages.${system}.flash.override { inherit firmware; }).overrideAttrs
                    (old: {
                      meta = (old.meta or { }) // {
                        platforms = lib.platforms.linux;
                      };
                    });
              }
            ) registry.keyboards
          );
        in
        # nix build github:semi710/zmk-config builds the default keyboard
        keyboards
        // {
          default = keyboards.${registry.default};
          inherit (zmk-nix.packages.${system}) update;
        }
      );
    };
}
