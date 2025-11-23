# SSH Key Switcher (skw)

A simple command-line tool to manage multiple SSH key profiles. Easily switch between different SSH keys for work, personal projects, or different services.

## Features

- 🔐 Manage multiple SSH key profiles in separate directories
- 🔄 Quick switching between profiles with automatic backups
- 🛡️ Automatic SSH agent integration
- 💾 Automatic backups before switching
- 🎨 Colorful, user-friendly CLI interface
- 📦 Zero dependencies (uses only standard Unix tools)
- 🚀 Fast and lightweight shell script

## Installation

### 🚀 Quick Install (One-liner)

The fastest way to install - downloads and runs the installer automatically:

```bash
curl -sSL https://raw.githubusercontent.com/AnthonyQuy/ssh-key-switcher/main/install.sh | bash
```

This will:
- ✅ Download and install skw
- ✅ Auto-detect your shell (bash/zsh)
- ✅ Configure PATH automatically
- ✅ Check dependencies

**Security Note:** You can inspect the install script first:
```bash
curl -sSL https://raw.githubusercontent.com/AnthonyQuy/ssh-key-switcher/main/install.sh | less
```

### 📦 Standard Install (Clone Repository)

If you prefer to clone the repository first:

```bash
git clone https://github.com/AnthonyQuy/ssh-key-switcher.git
cd ssh-key-switcher
./install.sh
```

### 🔧 Direct Download (Manual)

For minimal automation - just download the script:

```bash
# Download skw to local bin
mkdir -p ~/.local/bin
curl -sSL https://raw.githubusercontent.com/AnthonyQuy/ssh-key-switcher/main/skw -o ~/.local/bin/skw
chmod +x ~/.local/bin/skw

# Add to PATH (add this to ~/.zshrc or ~/.bashrc)
export PATH="$HOME/.local/bin:$PATH"

# Reload shell
source ~/.zshrc  # or ~/.bashrc
```

## Quick Start

```bash
# Initialize the tool
skw init

# Create profiles for different contexts
skw add work             # SSH key for work projects
skw add personal         # SSH key for personal projects
skw add github-corp      # SSH key for corporate GitHub

# Switch between profiles
skw use work             # Use work SSH key
skw use personal         # Use personal SSH key

# List all profiles
skw list                 # See all profiles (active marked with *)

# Check current profile
skw current              # Display currently active profile
```

## Commands

### `skw init`
Initialize SSH Key Switcher. Creates necessary directories and optionally migrates existing keys.

```bash
skw init
```

### `skw add <profile-name>`
Create a new SSH key profile with interactive prompts.

```bash
skw add work
skw add personal
skw add github-personal
```

Options during creation:
- **Key Type**: ED25519 (recommended), RSA 4096, or ECDSA 521
- **Email/Comment**: Optional identifier for the key
- **Passphrase**: Optional (recommended for security)

### `skw use <profile-name>`
Switch to a different SSH key profile. Automatically backs up current keys and updates SSH agent.

```bash
skw use work
skw use personal
```

### `skw list` (or `skw ls`)
List all available profiles with key fingerprints. Active profile is marked with `*`.

```bash
skw list
```

Example output:
```
Available SSH key profiles:

* work (active)
    256 SHA256:abc123... (ED25519)

  personal
    4096 SHA256:def456... (RSA)

  github
    256 SHA256:ghi789... (ED25519)
```

### `skw current`
Display the currently active profile and key fingerprint.

```bash
skw current
```

### `skw remove <profile-name>` (or `skw rm`)
Remove a profile. Requires confirmation and prevents removal of active profile.

```bash
skw remove old-profile
```

### `skw organize`
Interactively scan for unmanaged SSH keys and organize them into profiles. This command:
- Scans `~/.ssh/` for keys not already in profiles
- Shows details for each unmanaged key (type, fingerprint, comment)
- Lets you assign a profile name for each key
- Creates new profiles if needed
- Backs up keys before organizing

```bash
skw organize
```

Example session:
```
$ skw organize

Scanning ~/.ssh/ for unmanaged keys...
Found 2 unmanaged key(s)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Key 1/2: id_rsa_old
  Type: RSA 4096
  Fingerprint: SHA256:abc123...
  Comment: old-laptop

Enter profile name for this key (or 'skip'): legacy
✓ Created new profile: legacy
✓ Moved id_rsa_old to profile 'legacy' as id_rsa

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Summary:
  ✓ 1 key(s) organized into profiles
  • 1 key(s) skipped
```

### `skw backup`
Create a manual backup of current SSH keys.

```bash
skw backup
```

### `skw help`
Show help information with all commands and examples.

```bash
skw help
```

### `skw version`
Show version information.

```bash
skw version
```

## Directory Structure

```
~/.ssh/                    # Standard SSH directory
~/.ssh-profiles/           # Profile storage
  ├── work/
  │   ├── id_ed25519
  │   ├── id_ed25519.pub
  │   └── config (optional)
  ├── personal/
  │   ├── id_rsa
  │   └── id_rsa.pub
  └── .current-profile     # Tracks active profile
~/.ssh-backup/             # Automatic backups
  ├── backup_20250123_143022/
  └── manual_backup_20250123_150000/
```

## Use Cases

### Separate Work and Personal Keys

```bash
# Set up work and personal profiles
skw init
skw add work
skw add personal

# Use work key during work hours
skw use work
git clone git@github.com:company/repo.git

# Switch to personal for side projects
skw use personal
git clone git@github.com:myusername/personal-project.git
```

### Multiple GitHub Accounts

```bash
# Create separate profiles for different GitHub accounts
skw add github-work
skw add github-personal

# Switch as needed
skw use github-work
git push origin main

skw use github-personal
git push origin main
```

### Different Keys for Different Services

```bash
# Create profiles for different services
skw add aws-ec2
skw add digital-ocean
skw add github

# Use the appropriate key for each service
skw use aws-ec2
ssh user@ec2-instance.amazonaws.com

skw use digital-ocean
ssh root@droplet-ip-address
```

## Safety Features

- **Automatic Backups**: Every time you switch profiles, current keys are backed up with a timestamp
- **Permission Management**: Automatically sets correct permissions (600 for private keys, 644 for public keys)
- **Active Profile Protection**: Cannot remove the currently active profile
- **SSH Agent Integration**: Automatically updates SSH agent with new keys
- **Confirmation Prompts**: Destructive operations require confirmation

## Troubleshooting

### skw command not found

If you get "command not found" after installation:

1. Check if the installation directory is in your PATH:
   ```bash
   echo $PATH
   ```

2. Add to your PATH by adding this to `~/.bashrc` or `~/.zshrc`:
   ```bash
   export PATH="$HOME/.local/bin:$PATH"
   ```

3. Reload your shell:
   ```bash
   source ~/.bashrc  # or source ~/.zshrc
   ```

### SSH agent not updating

If the SSH agent doesn't update automatically:

```bash
# Manually add the key
ssh-add ~/.ssh/id_ed25519

# Or restart SSH agent
eval "$(ssh-agent -s)"
skw use <profile-name>
```

### Permission denied errors

If you see permission errors:

```bash
# Fix permissions manually
chmod 600 ~/.ssh/id_*
chmod 644 ~/.ssh/id_*.pub
chmod 700 ~/.ssh
```

### Profile not switching

If a profile doesn't seem to switch:

1. Check if the profile exists:
   ```bash
   skw list
   ```

2. Verify current profile:
   ```bash
   skw current
   ```

3. Check SSH directory:
   ```bash
   ls -la ~/.ssh/
   ```

## Uninstallation

To uninstall SSH Key Switcher:

```bash
cd ssh-key-switcher
./uninstall.sh
```

The uninstaller will:
1. Remove the `skw` command
2. Optionally remove profile and backup directories

Note: Your SSH keys are safely stored in `~/.ssh-profiles/` and won't be deleted unless you explicitly choose to remove them.

## Requirements

- Unix-like operating system (macOS, Linux, BSD)
- OpenSSH client tools (`ssh-keygen`, `ssh-add`)
- Standard shell (`sh`, `bash`, or `zsh`)

## Security Considerations

- Private keys are stored with 600 permissions (owner read/write only)
- Public keys are stored with 644 permissions (owner read/write, others read)
- All backups maintain original permissions
- Profile directories are only accessible by the owner
- SSH agent integration uses system's ssh-agent

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

MIT License - see LICENSE file for details

## Author

Created to simplify SSH key management for developers working with multiple accounts and services.

## Changelog

### v1.0.0 (2025-01-23)
- Initial release
- Support for multiple SSH key profiles
- Automatic backup functionality
- SSH agent integration
- Interactive profile creation
- Profile management commands (add, use, list, remove)

## Support

If you encounter any issues or have questions:
1. Review existing [GitHub Issues](https://github.com/AnthonyQuy/ssh-key-switcher/issues)
2. Create a new issue with details about your problem
