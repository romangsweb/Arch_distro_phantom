// ╔══════════════════════════════════════════════════════════════╗
// ║  FIREFOX — user.js (Privacy · Performance · Hardening)       ║
// ║  Serious config for someone who knows what they're doing      ║
// ╚══════════════════════════════════════════════════════════════╝

// ── Appearance ─────────────────────────────────────────────────
user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);  // Enable userChrome.css
user_pref("browser.compactmode.show", true);
user_pref("browser.uidensity", 1);  // Compact mode
user_pref("browser.tabs.tabMinWidth", 80);
user_pref("ui.systemUsesDarkTheme", 1);
user_pref("devtools.theme", "dark");

// ── New Tab & Homepage ────────────────────────────────────────
user_pref("browser.newtabpage.enabled", false);
user_pref("browser.startup.homepage", "about:blank");
user_pref("browser.startup.page", 3);  // Restore previous session
user_pref("browser.newtabpage.activity-stream.feeds.section.topstories", false);
user_pref("browser.newtabpage.activity-stream.feeds.topsites", false);
user_pref("browser.newtabpage.activity-stream.showSponsored", false);
user_pref("browser.newtabpage.activity-stream.showSponsoredTopSites", false);

// ── Privacy ────────────────────────────────────────────────────
user_pref("privacy.trackingprotection.enabled", true);
user_pref("privacy.trackingprotection.socialtracking.enabled", true);
user_pref("privacy.donottrackheader.enabled", true);
user_pref("privacy.firstparty.isolate", true);
user_pref("privacy.resistFingerprinting", false);  // Breaks some sites
user_pref("network.cookie.cookieBehavior", 5);  // Total Cookie Protection
user_pref("dom.security.https_only_mode", true);
user_pref("dom.security.https_only_mode_ever_enabled", true);

// ── Telemetry Off ──────────────────────────────────────────────
user_pref("toolkit.telemetry.enabled", false);
user_pref("toolkit.telemetry.unified", false);
user_pref("toolkit.telemetry.archive.enabled", false);
user_pref("datareporting.healthreport.uploadEnabled", false);
user_pref("datareporting.policy.dataSubmissionEnabled", false);
user_pref("browser.ping-centre.telemetry", false);
user_pref("app.shield.optoutstudies.enabled", false);
user_pref("browser.discovery.enabled", false);
user_pref("browser.newtabpage.activity-stream.telemetry", false);

// ── Performance ────────────────────────────────────────────────
user_pref("gfx.webrender.all", true);
user_pref("media.hardware-video-decoding.enabled", true);
user_pref("layers.acceleration.force-enabled", true);
user_pref("network.http.max-persistent-connections-per-server", 10);
user_pref("browser.cache.disk.enable", true);
user_pref("browser.cache.memory.enable", true);

// ── Wayland ────────────────────────────────────────────────────
user_pref("widget.use-xdg-desktop-portal.file-picker", 1);
user_pref("widget.use-xdg-desktop-portal.mime-handler", 1);

// ── Dev Tools ──────────────────────────────────────────────────
user_pref("devtools.chrome.enabled", true);
user_pref("devtools.debugger.remote-enabled", false);
user_pref("devtools.inspector.showUserAgentStyles", true);

// ── Misc ───────────────────────────────────────────────────────
user_pref("browser.aboutConfig.showWarning", false);
user_pref("browser.shell.checkDefaultBrowser", false);
user_pref("browser.urlbar.suggest.searches", true);
user_pref("browser.urlbar.suggest.engines", false);
user_pref("full-screen-api.warning.timeout", 0);  // No fullscreen warning
user_pref("media.videocontrols.picture-in-picture.enabled", true);
user_pref("reader.content_width", 5);
