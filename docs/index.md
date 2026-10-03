# zmk-config

ZMK keyboard firmware configs, built with [nix](https://nixos.org) via
[zmk-nix](https://github.com/lilyinstarlight/zmk-nix). One directory per
keyboard under `keyboards/`, one registry entry in `keyboards.nix` - future
keyboards plug in without touching the build logic.

## Keyboards

| Keyboard | Board | Shield | Display |
|----------|-------|--------|---------|
| [corne](keyboards/corne.md) | nice!nano v2 | `corne_%PART% nice_oled` | 2x 128x32 OLED |

## Build

```bash
nix build github:semi710/zmk-config        # default keyboard -> result/zmk_{left,right}.uf2
nix build github:semi710/zmk-config#corne  # explicit keyboard
nix run github:semi710/zmk-config#flash-corne  # interactive flash (Linux, copies uf2 to the mounted controller)
nix run github:semi710/zmk-config#update   # bump west deps, prints the new zephyrDepsHash
```

CI builds every keyboard on push and publishes the uf2s as the `firmware`
artifact and as the rolling `latest` release - every push leaves a
downloadable firmware. `v*` tags cut versioned releases.

```bash
gh release download latest -R semi710/zmk-config    # newest firmware
```

The flake also exposes `flakeModules.default` so other flakes can
consume the keyboards as packages - see the [Flake Module](module.md) page.

## Consume from another flake

```nix
# flake.nix
{
  inputs.zmk-config.url = "github:semi710/zmk-config";

  outputs = inputs:
    inputs.nix-wire.mkFlake { inherit inputs; } {
      imports = [ inputs.zmk-config.flakeModules.default ];
    };
}
```

This adds `packages.zmk` / `packages.zmk-flash` (the default keyboard) and
`packages.zmk-<name>` / `packages.zmk-flash-<name>` for every keyboard.
