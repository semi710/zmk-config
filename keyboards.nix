{
  default = "corne";

  keyboards = {
    corne = {
      board = "nice_nano_v2";
      shield = "corne_%PART% nice_oled";
      enableZmkStudio = true;
      zephyrDepsHash = "sha256-ev0tKrvO4n7g2+4+DqfjWMQhG2zMMOM4tlWp60L7vuc=";
      # applied to the zmk-nice-oled west module in postConfigure
      patches = [
        "keyboards/corne/patches/nice-oled-layer-dots.patch"
        "keyboards/corne/patches/nice-oled-bongo-speed.patch"
        "keyboards/corne/patches/nice-oled-pressed-key.patch"
      ];
    };
  };
}
