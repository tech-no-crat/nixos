# NixOS + this repo: install and customize (end-to-end)

This guide assumes you are starting from a fresh NixOS install and want to use this repository as your system configuration. It keeps the flow practical: first you get Git so you can clone, then you trim the repo, then you wire in your hardware config, then you apply the minimal Flake edits, and finally you customize `configuration.nix` by commenting out specific line numbers.

## 1) Install NixOS

Install NixOS normally.

## 2) Install Git (NixOS does not ship Git by default)

NixOS typically does not include Git out of the box, so you need to add it to the system packages before you can clone.

Open `/etc/nixos/configuration.nix` and add `git` under `environment.systemPackages`.

```nix
environment.systemPackages = with pkgs; [
  vim
  wget
  git  # add git
];
```

Apply the change:

```bash
sudo nixos-rebuild switch
```

Verify Git is installed:

```bash
which git
```

If it prints a path to the binary, Git is installed.

## 3) Set temporary Git identity (you will change this later)

Run these once so commits work if you need them:

```bash
git config --global user.name "Your Name"
```

```bash
git config --global user.email "Your Email"
```

## 4) Clone the repo

Go to your home directory:

```bash
cd ~
```

Clone:

```bash
git clone https://github.com/tech-no-crat/Flake.git
```

## 5) Prune the repo to keep it lean

You can delete or rename anything you do not require. To keep it lean, delete the following paths from inside the cloned repo.

Delete:

- `hardware-configuration.nix`
- `hosts/surface-book-passive`
- `hosts/surface-book-active`
- `flake.lock`
- `home/surface-book-passive`
- `home/surface-book-active`

## 6) Copy in your hardware configuration

Copy your hardware config from the installed system into the repo.

From your home directory:

```bash
cp /etc/nixos/hardware-configuration.nix ~/Flake/hardware-configuration.nix
```

This matches the `imports` in the `configuration.nix` you posted, which references `./hardware-configuration.nix`.

## 7) Edit `flake.nix`

Open `flake.nix` and make the following changes:

Remove lines 44-86.

Change `shyam` on line 39 to your username.

## 8) Edit `configuration.nix` (line-referenced customization)

Open the repo’s `configuration.nix` and use the guide below to make changes depending on what you need. The goal is that a fresh install can enable only what’s needed by commenting out specific lines.

---

# configuration.nix - Customization Guide (line-referenced)


Rule: if you comment out or delete a line, you remove that option from this system configuration and NixOS falls back to defaults or whatever other imported modules set.

## 0) Quick-start: the minimum edits for a fresh install

### Mandatory rename (username)

Change every occurrence of `shyam`:

- Line 55 `services.displayManager.autoLogin.user = "shyam";` -> set to your username.
- Lines 70-75 `users.users.shyam = { ... }` -> rename the attribute to your username and update line 72 if you care.
- Line 88 `nix.settings.trusted-users = [ "root" "shyam" ];` -> replace `shyam` with your username.

If you do not do this, you will either create a user literally named `shyam` (line 70) or auto-login/trust a user that does not exist (lines 55/88).

### Recommended (machine identity)

- Line 29 `networking.hostName = "nixos";` -> set to a meaningful hostname.

### Recommended (interface names)

- Lines 31-32 reference `eno1` and `wlp11s0`. If your NIC names differ, those Wake-on-LAN settings will not apply.

## 1) Feature toggles: what to comment out when you do not want something

### A) Do not want Sunshine / Steam / 1Password modules

Remove the corresponding import line:

- Remove line 7 to stop loading `sunshine.nix`.
- Remove line 8 to stop loading `steam.nix`.
- Remove line 9 to stop loading `1password.nix`.

Effect: the settings from those modules are not applied. Nothing else in this `configuration.nix` file replaces what those modules might have done.

### B) Do not want SSH access at all

- Remove line 40 `services.openssh.enable = true;`

Effect: the SSH daemon will not be enabled by this file.

### C) Want SSH enabled but not open on port 22

- Keep line 40 so the SSH service is enabled.
- Remove line 36 `networking.firewall.allowedTCPPorts = [ 22 ];`

Effect: SSH can run, but inbound connections on TCP/22 are typically blocked by the firewall (assuming line 35 remains enabled).

### D) Do not want the firewall at all

- Remove line 35 `networking.firewall.enable = true;`

Effect: the firewall is not enabled by this file. Lines 36-37 no longer matter.

### E) Do not want Wake-on-LAN

- Remove line 31 to disable WoL on `eno1`.
- Remove line 32 to disable WoL on `wlp11s0`.
- If you also opened UDP/9 only for WoL, remove line 37.

Effect: the system will not explicitly enable WoL on those interfaces, and UDP/9 will not be explicitly permitted.

### F) Do not want Tailscale

- Remove line 41 `services.tailscale.enable = true;`

Effect: tailscaled will not be enabled by this file.

### G) Do not want GNOME / do not want a graphical desktop

If you want no GUI:

- Remove line 45 (`services.xserver.enable = true;`) or remove the whole block 44-53.

Effect: you stop enabling X server + desktop via this file.

If you want a GUI but do not want GDM:

- Remove line 47.

Effect: GNOME Display Manager will not be enabled by this file.

If you want a GUI but do not want GNOME:

- Remove line 48.

Effect: GNOME desktop environment is not enabled by this file.

### H) Do not want auto-login

- Remove line 54.

Effect: users must log in normally.

### I) Do not want printing

- Remove line 58.

Effect: printing (CUPS) will not be enabled by this file.

If you want printing but do not want the Samsung/SPLIX drivers:

- Remove lines 59-61.

Effect: those specific drivers will not be installed via this file.

### J) Do not want PipeWire audio

- Remove line 64 (or the whole block 63-67).

Effect: PipeWire is not enabled by this file.

If you keep PipeWire but do not want PulseAudio compatibility:

- Remove line 66.

Effect: applications expecting PulseAudio may lose audio.

### K) Do not want Firefox

- Remove line 84.

Effect: Firefox will not be enabled/installed via this option.

### L) Do not want unfree packages allowed

- Remove line 87.

Effect: unfree packages are not permitted by this configuration.

### M) Do not use flakes / nix-command

- Remove line 86.

Effect: `nix-command` and `flakes` features are not enabled by this file.

## 2) Hardware assumptions: what is most likely to break if changed

### Boot loader and EFI (lines 17-18)

- Removing line 17 may leave you without an explicitly configured bootloader.
- Removing line 18 stops writing EFI NVRAM variables, which can affect how entries are registered.

### AMD GPU early boot and driver selection (lines 19-26)

- Removing line 19 stops forcing `amdgpu` into initrd; early boot graphics may regress.
- Removing lines 21-22 stops forcing display modes.
- Removing line 26 allows the legacy `radeon` driver to load, which can change behavior or break the intended driver.

### Intel Wi-Fi module forcing (line 25)

- Removing line 25 stops forcing `iwlwifi` to load; Wi-Fi may not appear if it does not auto-load.

### Redistributable firmware (line 14)

- Removing line 14 can cause Wi-Fi/GPU firmware issues on hardware that needs those blobs.

## 3) Root tools only: systemPackages guidance

- Lines 79-82 install `vim` and `wget` system-wide.
- Removing 80 removes Vim.
- Removing 81 removes Wget.
- Removing 79-82 removes both.

Effect: these tools will not be available by default for root/system context.

## 4) Do not casually change: stateVersion

- Line 89 `system.stateVersion = "25.05";` pins compatibility defaults.

Removing it causes NixOS to complain because it is required. Changing it can change defaults across services even if you did not change anything else in this file.

## 5) If you only remember one thing

- Lines 6-10 decide what other files contribute settings.
- Lines 35-37 control the firewall and what is reachable from the network.
- Lines 40-41 control remote access services.
- Lines 44-55 control whether this is a GNOME desktop with auto-login.
- Lines 70-75 define the main user and their privileges.
