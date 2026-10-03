# Flake Module

`flakeModules.default` exposes every keyboard in this repo as packages in the
importing flake. It requires an input named `zmk-config`:

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

## What you get

| Package | Contents |
|---------|----------|
| `zmk` | default keyboard firmware (`zmk_left.uf2` + `zmk_right.uf2`) |
| `zmk-flash` | interactive flash helper for the default keyboard (Linux) |
| `zmk-<name>` | firmware for keyboard `<name>` |
| `zmk-flash-<name>` | flash helper for keyboard `<name>` (Linux) |

The default keyboard is `default` in `keyboards.nix`.

```bash
nix build .#zmk           # default keyboard
nix build .#zmk-corne     # explicit
nix run .#zmk-flash       # flash on a Linux host with the keyboard mounted
```

## Adding a keyboard

1. `keyboards/<name>/` with `west.yml` (`self.path: <name>`), `<name>.conf`,
   `<name>.keymap`, and optional `patches/`
2. Register it in `keyboards.nix`:

```nix
keyboards = {
  corne = { ... };
  sofle = {
    board = "nice_nano_v2";
    shield = "sofle_%PART% nice_oled";
    zephyrDepsHash = "sha256-...";
    # patches = [ "keyboards/sofle/patches/*.patch" ];
  };
};
```

3. Run `nix build .#sofle`, paste the `got:` hash from the mismatch error
4. Add the keyboard to the CI matrix in `.github/workflows/build.yml`

Consumers get `packages.zmk-sofle` on the next input bump - no changes needed
in the importing flake.
