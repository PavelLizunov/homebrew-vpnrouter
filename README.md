# Homebrew Tap for VPNRouter

Public [Homebrew Cask](https://docs.brew.sh/Cask-Cookbook) tap for
[VPNRouter](https://github.com/PavelLizunov/VPNRouter) — a process-based
split-tunnel VPN router that routes selected applications through a
VLESS+Reality proxy via [sing-box](https://github.com/SagerNet/sing-box)
TUN mode, everything else goes direct.

## Install

```bash
brew tap pavellizunov/vpnrouter
brew install --cask vpnrouter
```

Or in a single line:

```bash
brew install --cask pavellizunov/vpnrouter/vpnrouter
```

## Update

```bash
brew upgrade --cask vpnrouter
```

## Uninstall

```bash
brew uninstall --cask vpnrouter
# optional: also remove user-level state
brew uninstall --zap --cask vpnrouter
# optional: remove sudoers NOPASSWD entry (VPNRouter writes this on
# first Connect so sing-box TUN brings up without a password prompt)
sudo rm /etc/sudoers.d/vpnrouter
```

## First launch

The DMG is **not signed or notarized** (no Apple Developer account).
When you download it from GitHub via Safari, macOS Gatekeeper blocks
it with "VPNRouter.app can't be opened because Apple cannot check it
for malicious software".

**Homebrew Cask fixes this automatically** — `brew install --cask`
uses `curl`, which doesn't set the `com.apple.quarantine` xattr, so
Gatekeeper doesn't kick in. The app launches cleanly the first time.

On first Connect, the app walks you through writing a NOPASSWD entry
into `/etc/sudoers.d/vpnrouter` so the bundled sing-box can create a
TUN adapter without prompting for a password on every start. This is
the macOS equivalent of the setcap-based passwordless flow used on
Linux via the `.deb` post-install hook.

## Requirements

- **macOS 12 (Monterey) or later** — matches `Info.plist
  LSMinimumSystemVersion`
- **Apple Silicon (arm64)** — the DMG is arm64-only. Intel users can
  use the Linux `.deb` / AppImage in a VM, or wait for a universal
  build

## Why a custom tap, not `homebrew-cask`?

Same reason every major VPN provider (Mullvad, ProtonVPN, Tailscale,
Cloudflare WARP) ships their own tap or repo: fast iteration without
being gated by Homebrew/homebrew-cask's review queue, and ability to
push security updates the moment a release ships. If VPNRouter
stabilises for a few months we may submit to the official
`homebrew-cask` repository too — they're complementary paths.

## Automation

This tap's `Casks/vpnrouter.rb` is auto-updated by the
[`update-cask.yml`](.github/workflows/update-cask.yml) workflow on
every stable VPNRouter release. That workflow is triggered from the
main repository's `build-mac.yml` via `repository_dispatch`, downloads
the fresh DMG, computes its SHA256, bumps `version` and `sha256` in
the cask file, and opens a commit back to `main`.

## Links

- [Main VPNRouter repo](https://github.com/PavelLizunov/VPNRouter)
- [APT repo (Debian/Ubuntu)](https://vpn.ninitux.com/apt/)
- [One-liner installer (Linux)](https://vpn.ninitux.com/install.sh)
- [GitHub Releases (all platforms)](https://github.com/PavelLizunov/VPNRouter/releases)
