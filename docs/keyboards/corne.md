# Corne

42-key split keyboard on nice!nano v2 controllers with 128x32 OLEDs, built
with [ZMK](https://zmk.dev) pinned to `v0.3`.

## Board

```
      ┌─────── OLED 128x32 ───────┐      ┌─────── OLED 128x32 ───────┐
      │ cat·bt·batt·mods·dots·key │      │      cat·batt·link        │
      └───────────────────────────┘      └───────────────────────────┘
      ┌───┬───┬───┬───┬───┬───┐          ┌───┬───┬───┬───┬───┬───┐
      │   │   │   │   │   │   │          │   │   │   │   │   │   │
      │   │   │   │   │   │   │          │   │   │   │   │   │   │
      │   │   │   │   │   │   │          │   │   │   │   │   │   │
      └───┴───┴───┴───┴───┴───┘          └───┴───┴───┴───┴───┴───┘
        ┌───┬───┬───┐                      ┌───┬───┬───┐
        │   │   │   │                      │   │   │   │
        └───┴───┴───┘                      └───┴───┴───┘
      nice!nano v2                        nice!nano v2
       (central)                          (peripheral)
```

- 3x6 keys + 3-key thumb arc per half; columns run straight - Tab sits
  directly above the esc/hyper key. The stagger is vertical only: outer
  columns sit ~0.3u lower than the middle (like finger lengths), never
  sideways
- Each half runs its own nice!nano v2 with a LiPo cell - the halves talk to
  each other over BLE (the TRRS jack is unused in this wireless build), and
  the left half (central) resolves all keymap behavior
- Double-tap the reset button on a half to expose the UF2 bootloader
  (`NICENANO` volume) - copying an uf2 onto it flashes that half
- Only the central (left) firmware changes with keymap edits; the peripheral
  build is keymap-independent

## Structure

| File | Purpose |
|------|---------|
| `keyboards/corne/west.yml` | West manifest, pins ZMK `v0.3` + the OLED module |
| `keyboards/corne/corne.keymap` | Keymap - layers, behaviors, combos |
| `keyboards/corne/corne.conf` | Board config - OLED, sleep, BLE tuning |
| `keyboards/corne/patches/` | OLED module patches, applied at build time ([details](#oled)) |

## Layout

`X→MOD` = tap sends the letter, hold acts as the modifier (cross-hand holds only).
`·` = transparent - falls through to the layer below, so home-row mods work through layers.

### Base

```
┌─────┬─────┬─────┬─────┬─────┬─────┐   ┌─────┬─────┬─────┬─────┬─────┬─────┐
│ TAB │  Q  │  W  │  E  │  R  │  T  │   │  Y  │  U  │  I  │  O  │  P  │ BSPC│
├─────┼─────┼─────┼─────┼─────┼─────┤   ├─────┼─────┼─────┼─────┼─────┼─────┤
│⎋/HYP│A→SFT│S→CTL│D→ALT│F→GUI│  G  │   │  H  │J→GUI│K→ALT│L→CTL│;→SFT│  '  │
├─────┼─────┼─────┼─────┼─────┼─────┤   ├─────┼─────┼─────┼─────┼─────┼─────┤
│SHFT │  Z  │  X  │  C  │  V  │  B  │   │  N  │  M  │  ,  │  .  │  /  │ ESC │
└─────┴─────┴─────┴─────┴─────┴─────┘   └─────┴─────┴─────┴─────┴─────┴─────┘
               ┌─────┬─────┬─────┐   ┌─────┬─────┬─────┐
               │ GUI │ LWR │SPC/H│   │ENT/H│ RSE │A/GUI│
               └─────┴─────┴─────┘   └─────┴─────┴─────┘
```

`⎋/HYP` = tap sends `Esc`, hold acts as Hyper (Cmd+Alt+Ctrl) - the capslock pattern.

The left outer thumb is a plain `Gui` - always Cmd, no hold-tap latency.

`SPC/H` and `ENT/H` = tap sends Space / Return, hold acts as Hyper.
`space, space<hold>` auto-repeats space, `enter, enter<hold>` auto-repeats
enter; a lone hold past the tapping term fires Hyper (Cmd+Alt+Ctrl) for app
shortcuts and window management. `A/GUI` mirrors it on the right: tap sends
`Alt`, hold acts as `Gui`.

Double-tap-hold: tap a hold-tap key, then press it again within 250 ms
(`quick-tap-ms`) and hold - the tap fires immediately and auto-repeats.
`j, j<hold>` gives a held `j` (continuous scroll in the browser) instead of
the home-row mod.

### Lower (hold LWR) - numbers, BT profiles, navigation

```
┌─────┬─────┬─────┬─────┬─────┬─────┐   ┌─────┬─────┬─────┬─────┬─────┬─────┐
│ TAB │  1  │  2  │  3  │  4  │  5  │   │  6  │  7  │  8  │  9  │  0  │ BSPC│
├─────┼─────┼─────┼─────┼─────┼─────┤   ├─────┼─────┼─────┼─────┼─────┼─────┤
│BTCLR│ BT1 │ BT2 │ BT3 │ BT4 │ BT5 │   │  ←  │  ↓  │  ↑  │  →  │ TAB │  ·  │
├─────┼─────┼─────┼─────┼─────┼─────┤   ├─────┼─────┼─────┼─────┼─────┼─────┤
│SHFT │  ·  │  ·  │  ·  │  ·  │  ·  │   │  ·  │  ·  │  ·  │  ·  │  ·  │  ·  │
└─────┴─────┴─────┴─────┴─────┴─────┘   └─────┴─────┴─────┴─────┴─────┴─────┘
               ┌─────┬─────┬─────┐   ┌─────┬─────┬─────┐
               │ GUI │  ·  │ SPC │   │ ENT │  ·  │ ALT │
               └─────┴─────┴─────┘   └─────┴─────┴─────┘
```

### Raise (hold RSE) - symbols

```
┌─────┬─────┬─────┬─────┬─────┬─────┐   ┌─────┬─────┬─────┬─────┬─────┬─────┐
│ TAB │  !  │  @  │  #  │  $  │  %  │   │  ^  │  &  │  *  │  (  │  )  │ BSPC│
├─────┼─────┼─────┼─────┼─────┼─────┤   ├─────┼─────┼─────┼─────┼─────┼─────┤
│CTRL │  ·  │  ·  │  ·  │  ·  │  ·  │   │  -  │  =  │  [  │  ]  │  \  │  `  │
├─────┼─────┼─────┼─────┼─────┼─────┤   ├─────┼─────┼─────┼─────┼─────┼─────┤
│SHFT │  ·  │  ·  │  ·  │  ·  │  ·  │   │  _  │  +  │  {  │  }  │  |  │  ~  │
└─────┴─────┴─────┴─────┴─────┴─────┘   └─────┴─────┴─────┴─────┴─────┴─────┘
               ┌─────┬─────┬─────┐   ┌─────┬─────┬─────┐
               │ GUI │  ·  │ SPC │   │ ENT │  ·  │ ALT │
               └─────┴─────┴─────┘   └─────┴─────┴─────┘
```

## OLED

Both halves carry 128x32 OLEDs driven by
[zmk-nice-oled](https://github.com/mctechnology17/zmk-nice-oled), fetched via
west at build time. Left (central) screen: bongo cat whose speed follows
typing, BT profile number, battery, modifier symbols, layer dots + the glyph
of the last pressed key. Right (peripheral) screen: looping cat animation,
battery, connection icon - layer/BT/mod state never crosses the split link,
so a peripheral can only show what it knows locally.

The three dots are the **layer indicator** (centered in the visible strip -
the 68x160 module canvas maps onto the 128x32 display through a 90° rotation,
so only a 32px slice of canvas X is on-screen); the number by the BT icon is
the active **Bluetooth profile**; the glyph column shows the last pressed
characters - shift-aware, rolling history that clears after 2s idle.

### Patches

`keyboards/corne/patches/` carries diffs against the OLED module: layer dots,
bongo cat speed, pressed-key display. Plain `patches =` cannot work here -
stdenv applies them before west fetches the module - so the flake applies them
in `postConfigure`, after the module sources land in the build tree. A
`zephyrDepsHash` bump that changes the patched lines upstream fails the
build loudly at `git apply` and the patch needs a refresh.

## Build

```bash
nix build .#corne           # result/zmk_{left,right}.uf2
nix run .#flash-corne        # interactive flash (Linux)
nix run .#update             # bump west deps, prints the new zephyrDepsHash
```

- ZMK stays pinned by `west.yml` (v0.3); the west deps are locked by
  `zephyrDepsHash` in `keyboards.nix`
- zmk-nix rides nixpkgs stable - Zephyr 3.5's build scripts predate python
  3.14's `pkg_resources` removal in unstable's setuptools
- Bumping ZMK: edit `west.yml`, run `nix build .#corne`, paste the new `got:`
  hash from the mismatch error into `keyboards.nix`

## Flash (nice!nano v2)

1. Double-tap the reset button - the half mounts as a USB drive (`NICENANO`)
2. Copy the matching `.uf2` from `result/` (local build) or the CI `firmware`
   artifact:
    - left half -> `zmk_left.uf2`
    - right half -> `zmk_right.uf2`
3. The half reboots automatically once the file is copied

The halves must run matching firmware versions to talk to each other -
flash both back-to-back and expect the keyboard dead in between.

## ZMK Studio

Both halves build with the `studio-rpc-usb-uart` snippet and `CONFIG_ZMK_STUDIO=y`,
so the keymap can be tweaked live over USB with
[ZMK Studio](https://zmk.dev/studio) without reflashing. The unlock combo is
pressing `TAB` + `Q` together.

!!! note
    Studio edits are runtime-only. Lasting changes go in `keyboards/corne/corne.keymap`.
