![QuantumQat Logo](assets/logo.jpg)

# QuantumQat
[![build-quantumqat](https://github.com/alfredgamulo/quantumqat/actions/workflows/build.yml/badge.svg)](https://github.com/alfredgamulo/quantumqat/actions/workflows/build.yml)

QuantumQat is a custom [Bazzite](https://bazzite.gg/) image for people who identify as gamers first, and as hackers second. It is rebuilt nightly on top of the latest Bazzite.

Huge thanks to the projects this stands on:
- [Bazzite](https://bazzite.gg/)
- [Universal Blue](https://github.com/ublue-os)
- [BlueBuild](https://blue-build.org/) — the tool used to build this image

# How it's built

This image is built with [**BlueBuild**](https://blue-build.org/), not a hand-written `Containerfile`. The whole image is described declaratively in [`recipes/recipe.yml`](recipes/recipe.yml): a base image plus an ordered list of **modules** (install packages, copy files, enable services, …). BlueBuild's CLI turns that recipe into an OCI image.

> Historical note: this repo was originally a raw `Containerfile` fork of the [ublue-os/image-template](https://github.com/ublue-os/image-template) pattern. It was migrated to BlueBuild because the `bling` module (which installs 1Password) now relies on BlueBuild's build pipeline — see the git history if you need the full story.

## Repository layout

| Path | What it is |
|------|-----------|
| [`recipes/recipe.yml`](recipes/recipe.yml) | **Start here.** The image definition: base image + the ordered list of modules. |
| `files/system/` | Files copied verbatim into the image root (e.g. `/etc`, `/usr`). |
| `files/scripts/` | Build-time shell scripts, run by `type: script` modules in the recipe. |
| `files/dnf/` | `.repo` files consumed by the `dnf` module (Docker CE, VS Code). |
| `files/justfiles/` | `ujust` recipes baked into the image. |
| `installer/` | Lorax templates + config used when building the offline ISO. |
| `.github/workflows/build.yml` | CI: build → sign → push → build ISO. |
| `cosign.pub` | Public signing key. The private half is the `SIGNING_SECRET` repo secret. |

## Making changes

Almost everything is a one-liner in [`recipes/recipe.yml`](recipes/recipe.yml):

| To… | Edit |
|-----|------|
| Install an RPM | add it to the `dnf` module's `install.packages` |
| Install a Flatpak | add its app id to the `default-flatpaks` module |
| Enable a systemd unit | add it to the `systemd` module's `system.enabled` |
| Ship a config file | drop it under `files/system/` at its target path |
| Run a custom build step | add a script to `files/scripts/` and list it in a `type: script` module |
| Add a `ujust` command | add a recipe to `files/justfiles/100-quantumqat.just` |

Module options are documented at [blue-build.org/reference/modules](https://blue-build.org/reference/modules/).

## Building locally

Install the [BlueBuild CLI](https://blue-build.org/how-to/setup/), then:

```bash
just build       # build the image
just build-iso   # build an offline installer ISO
```

# Installing

## Rebasing from an existing Universal Blue system

Because the image is [cosign](https://www.sigstore.dev/)-signed, the **first** rebase is two steps: rebase to the unverified image once (it ships the signing policy), then to the signed image so future updates are verified.

```bash
# 1. Rebase to the unverified image, then reboot
rpm-ostree rebase ostree-unverified-registry:ghcr.io/alfredgamulo/quantumqat:latest
systemctl reboot

# 2. Rebase to the signed image, then reboot
rpm-ostree rebase ostree-image-signed:docker://ghcr.io/alfredgamulo/quantumqat:latest
systemctl reboot
```

After that, updates arrive automatically through the normal system updater (Bazzite uses `bootc`/`rpm-ostree` under the hood) — no further action needed.

## Fresh install from an ISO

Build an [offline-installable ISO](https://blue-build.org/learn/universal-blue/#fresh-install-from-an-iso) with `just build-iso` (see [Building locally](#building-locally)), or download the ISO artifact from a CI run.

# 1Password browser integration

The native 1Password app (installed via the `bling` module) **cannot talk to a Flatpak browser's extension out of the box** — the Flatpak sandbox blocks the native-messaging connection 1Password uses.

This image bakes the system-side allowlist ([`/etc/1password/custom_allowed_browsers`](files/system/etc/1password/custom_allowed_browsers)). The rest of the bridge — a wrapper script, the browser's native-messaging manifest, and a `flatpak override` — lives under each user's `~/.var/app/…`, so it **can't** be baked into the image and must be run once per user:

```bash
ujust setup-1password-browser            # brave (default)
ujust setup-1password-browser firefox
ujust setup-1password-browser chrome
ujust setup-1password-browser com.google.Chrome   # or any Flatpak app id
```

Run it **after** the browser Flatpak is installed. Then restart the browser and the 1Password app, and enable "Integrate with 1Password" in the extension settings. Both Chromium- and Firefox-based browsers are supported. The underlying logic lives in [`files/system/usr/libexec/quantumqat/setup-1password-browser`](files/system/usr/libexec/quantumqat/setup-1password-browser); it is adapted from [FlyinPancake/1password-flatpak-browser-integration](https://github.com/FlyinPancake/1password-flatpak-browser-integration).

> **Possible improvement (not implemented):** this is a manual, per-user step. It could be automated by shipping a systemd **user** service (in `/usr/lib/systemd/user/`, enabled via the `systemd` module) that runs `setup-1password-browser` on each login, removing the `ujust` step. The tradeoff is more to maintain, and it can break if 1Password's extension IDs or the Flatpak paths change upstream.

# Maintainer notes

Things that aren't obvious from reading the recipe, for whoever returns to this after a long time:

- **Modules run top-to-bottom**, and the BlueBuild CLI is pinned by `blue-build/github-action@<version>` in [`build.yml`](.github/workflows/build.yml). Module behavior can change between CLI/module versions — a `bling` change is exactly what triggered the migration to BlueBuild.
- **`/opt` apps rely on BlueBuild's automatic optfix.** 1Password (via `bling`) and Winboat (via [`files/scripts/20-install-winboat.sh`](files/scripts/20-install-winboat.sh)) install into `/opt`. BlueBuild symlinks `/opt` → `/usr/lib/opt` during the build and recreates the runtime symlinks for you. **Do not** hand-roll `/opt` moves or tmpfiles — that is what broke 1Password before.
- **Don't rename `name:` in the recipe.** It is the published image ref (`ghcr.io/alfredgamulo/quantumqat`) that users have rebased onto; changing it silently breaks their updates.
- **Keep signing with the same key.** The image must keep being signed by the cosign key whose public half is [`cosign.pub`](cosign.pub) (private half = the `SIGNING_SECRET` secret). Rotating it breaks signed updates for existing installs.
- **Winboat is pinned and checksum-verified.** [`files/scripts/20-install-winboat.sh`](files/scripts/20-install-winboat.sh) installs an exact version and checks a vetted SHA-256 (the upstream RPM is unsigned, and no upstream checksum is published). To update it, bump `WINBOAT_VERSION` **and** `WINBOAT_SHA256` together — a mismatch fails the build by design. It does not auto-update; check the [Winboat releases](https://github.com/TibixDev/winboat/releases) periodically.
- **GitHub Actions are pinned to commit SHAs** with a `# vX` comment; Dependabot ([`.github/dependabot.yml`](.github/dependabot.yml)) opens PRs to bump them. Review those PRs rather than blindly merging.
- **Pinned third-party versions are watched by [`release-watch`](.github/workflows/release-watch.yml).** Dependabot can't track a version pinned in a shell script, so a weekly job compares each package listed in [`.github/release-watch.json`](.github/release-watch.json) against its upstream's latest release and opens an issue when a newer one exists. To watch another package whose version is pinned shell-style as `pin_key="<version>"`, add one entry (`name`, `repo`, `pin_file`, `pin_key`) — no workflow change needed. The job only fires an issue when upstream is strictly newer (version-ordered), and a package pinned in some other format fails the job loudly so you know the extraction step needs extending.

# Verifying signatures

These images are signed with [cosign](https://github.com/sigstore/cosign). Verify with the `cosign.pub` from this repo:

```bash
cosign verify --key cosign.pub ghcr.io/alfredgamulo/quantumqat
```
