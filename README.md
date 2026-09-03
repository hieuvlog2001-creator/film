# MisaMod Film — FIXED16

Fixes the FIXED15 verification failure. The Xcode build succeeds, but generated Info.plist did not contain CFBundleIconName. This workflow explicitly adds `CFBundleIconName=AppIcon` to the final unsigned app before packaging, then validates it.

Bundle ID: `site.misamod.film`
Version: 1.0.7 (Build 8)
iOS 15+
Unsigned IPA for eSign
