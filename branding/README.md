# ULTA Phone Android branding

`ulta-phone-icon-master.png` is the transparent high-resolution launcher artwork.
Run `generate_android_icons.ps1` from PowerShell after replacing the master to
regenerate legacy, round, adaptive, and Google Play icon assets.

The adaptive foreground deliberately keeps the complete artwork inside Android's
safe zone. Its navy background is defined as `ulta_phone_launcher_background` in
`app/src/main/res/values/colors.xml`.
