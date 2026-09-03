# MisaMod Film — FIXED17

Unsigned iOS IPA build.

This version uses `SFSafariViewController` as the primary web container so the site is loaded through the same Safari web stack/network path instead of WKWebView. This is intended to resolve WKWebView `NSURLErrorDomain -1004` connection failures when Safari can reach the site.

Bundle ID: `site.misamod.film`
Version: `1.0.8` (Build `9`)
