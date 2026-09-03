# MisaMod Film iOS — FIXED13

Unsigned iOS device IPA for eSign/self-signing.

- Bundle ID: `site.misamod.film`
- iOS 15+
- Complete AppIcon asset set included (iPhone, iPad, 1024px)
- `CFBundleIconName = AppIcon`
- Native iPhone user agent (no forced custom Safari UA)
- WKWebView with JavaScript, persistent cookies and inline video
- Detailed network error and Safari fallback
- GitHub Actions builds and packages an **unsigned** `iphoneos` IPA
- No Apple signing secrets are required

Run **Actions → Build MisaMod Film - Unsigned IPA** and download `MisaMod-Film-unsigned-IPA`.
Then sign the resulting `.ipa` with eSign or another compatible signing tool.
