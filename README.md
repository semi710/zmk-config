# zmk-config

ZMK keyboard firmware configs, built with [nix](https://nixos.org) via
[zmk-nix](https://github.com/lilyinstarlight/zmk-nix).

| Keyboard | Board | Display |
|----------|-------|---------|
| [corne](docs/keyboards/corne.md) | nice!nano v2 | 2x 128x32 OLED |

```bash
nix build .#corne     # result/zmk_{left,right}.uf2
nix run .#flash-corne  # interactive flash (Linux)
```

Consume from another flake via `flakeModules.default` - see the
[docs](https://semi710.github.io/zmk-config).
