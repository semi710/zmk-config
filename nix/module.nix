# flake-parts module for consumer flakes: exposes every keyboard in this repo
# as a package. Requires an input named `zmk-config`:
#
#   inputs.zmk-config.url = "github:semi710/zmk-config";
#   outputs = inputs: inputs.nix-wire.mkFlake { inherit inputs; } {
#     imports = [ inputs.zmk-config.flakeModules.default ];
#   };
{
  inputs,
  ...
}:
let
  registry = import "${inputs.zmk-config}/keyboards.nix";
  keyboards = builtins.attrNames registry.keyboards;
in
{
  perSystem =
    { system, ... }:
    let
      src = inputs.zmk-config.packages.${system};
    in
    {
      packages = builtins.listToAttrs (
        (map (n: {
          name = "zmk-${n}";
          value = src.${n};
        }) keyboards)
        ++ (map (n: {
          name = "zmk-flash-${n}";
          value = src."flash-${n}";
        }) keyboards)
        ++ [
          {
            name = "zmk";
            value = src.${registry.default};
          }
          {
            name = "zmk-flash";
            value = src."flash-${registry.default}";
          }
        ]
      );
    };
}
