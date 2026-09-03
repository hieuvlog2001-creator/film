# MisaMod Film — FIXED21

Unsigned iOS app for eSign.

- Native UIKit app shell
- Full-screen WKWebView inside the app (no Safari UI)
- Tries HTTPS/HTTP and www fallbacks for misamod.site
- AppIcon 1024x1024
- Bundle ID: site.misamod.film
- Version 1.1.2 (Build 13)
- iOS 15+
- GitHub Actions produces MisaModFilm-unsigned.ipa

If all four endpoints fail with NSURLError -1004, the iPhone/network cannot establish a connection to the server; an app wrapper cannot bypass an unreachable server.
