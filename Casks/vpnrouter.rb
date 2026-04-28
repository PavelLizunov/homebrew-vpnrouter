cask "vpnrouter" do
  version "2.28.6"
  sha256 "8c027da4c1cc0d9a0ff938949dff5692a2841ba03ff35011b67f330e6120360d"

  url "https://github.com/PavelLizunov/VPNRouter/releases/download/v#{version}/VPNRouter-v#{version}-mac.dmg",
      verified: "github.com/PavelLizunov/VPNRouter/"
  name "VPNRouter"
  desc "Process-based split-tunnel VPN router via VLESS+Reality (sing-box TUN)"
  homepage "https://github.com/PavelLizunov/VPNRouter"

  # Apple Silicon only for now — dotnet publish targets osx-arm64, and the
  # macOS DMG contains an arm64-only binary. Intel users should use the
  # tar.gz / Windows / Linux distribution, or wait for a universal build.
  depends_on arch: :arm64
  depends_on macos: ">= :monterey" # matches Info.plist LSMinimumSystemVersion=12.0

  app "VPNRouter.app"

  # Strip the com.apple.quarantine xattr that brew applies to unsigned DMG
  # downloads. Without this, macOS Gatekeeper shows "VPNRouter.app can't
  # be opened because Apple cannot check it for malicious software" on
  # first launch, and the nested sing-box binary hangs on amfid
  # verification when spawned by the app (sing-box is ad-hoc/linker-signed
  # only, inherits quarantine state from the parent .app).
  #
  # Also strip com.apple.provenance (added automatically by recent macOS
  # on downloaded content) — it interacts with amfid on first-launch
  # checks and introduces several-seconds hangs even after quarantine
  # is cleared.
  #
  # Rationale: we don't yet ship a Developer ID-signed + notarized build
  # (no Apple Dev account). Until we do, this postflight is the canonical
  # brew-cask pattern for unsigned apps from trusted sources — same as
  # what Mullvad / ProtonVPN / WireGuard use in their own taps.
  postflight do
    system_command "/usr/bin/xattr",
                   args: ["-rd", "com.apple.quarantine", "#{appdir}/VPNRouter.app"],
                   sudo: false
    system_command "/usr/bin/xattr",
                   args: ["-rd", "com.apple.provenance", "#{appdir}/VPNRouter.app"],
                   sudo: false
  end

  # First-run sudoers setup: the app guides the user through creating
  # /etc/sudoers.d/vpnrouter with a NOPASSWD entry for sing-box so the
  # TUN adapter can be brought up without a password prompt on every
  # Connect. See the InstallGuide.html bundled in the DMG for the one-time
  # two-line sudo command the user runs at first launch.
  #
  # brew uninstall doesn't touch /etc/sudoers.d (on purpose — it's outside
  # brew's jurisdiction). `zap` below offers the caller a way to clean the
  # user-level state (Application Support, preferences, logs) on
  # `brew uninstall --zap`. To fully remove the sudoers entry:
  #   sudo rm /etc/sudoers.d/vpnrouter
  zap trash: [
    "~/Library/Application Support/VPNRouter",
    "~/Library/Preferences/com.vpnrouter.app.plist",
    "~/Library/Logs/VPNRouter",
    "~/Library/Caches/com.vpnrouter.app",
  ]

  caveats <<~EOS
    VPNRouter needs root for TUN adapter creation.

    On first Connect the app pops a one-time password prompt and writes
    /etc/sudoers.d/vpnrouter with a NOPASSWD entry specifically for the
    bundled sing-box binary. After that, every VPN start is passwordless.

    To fully uninstall (including the sudoers entry):
      brew uninstall --zap --cask vpnrouter
      sudo rm /etc/sudoers.d/vpnrouter

    If you use Little Snitch / LuLu / other network monitors, the first
    Connect will surface prompts for VPNRouter.App and sing-box — allow
    both.
  EOS
end
