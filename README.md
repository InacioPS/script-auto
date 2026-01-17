# Script Auto - Automation Script for Package Installation

## Project Overview

This is a bash automation script (`install.sh`) designed to simplify package installation across different Linux distributions. The script supports major distribution families including Ubuntu/Debian-based systems, Arch Linux and derivatives, and includes special handling for AUR (Arch User Repository) packages.

### Key Features

- **Multi-distribution support**: Automatically detects the Linux distribution and uses appropriate package managers (apt for Ubuntu/Debian, pacman for Arch-based systems)
- **AUR integration**: Special handling for Arch Linux users to install packages from the AUR using `yay`
- **Comprehensive package lists**: Predefined lists of commonly used packages across categories (development, multimedia, utilities, etc.)
- **AppImage support**: Integration with AppImageSup for managing AppImage applications
- **Error handling**: Graceful handling of missing packages and installation failures
- **Root privilege enforcement**: Ensures the script runs with appropriate permissions

### Architecture

The script follows a modular approach with:

- Main package lists for official repositories
- Separate lists for AUR packages (Arch-based systems)
- Distribution detection logic
- Platform-specific installation functions
- Error reporting mechanisms

## Building and Running

### Prerequisites

- Root privileges (script must be run with `sudo`)
- Internet connection for package downloads

### Usage

```bash
sudo ./install.sh
```

### Configuration

The script contains three main package arrays that can be customized:

- `PACOTES`: Official repository packages (common to all distros)
- `AUR_PACOTES`: AUR packages (for Arch-based systems)
- `APPIMAGE`: AppImage applications

To customize the installation, edit these arrays in the script before running.

### Supported Distributions

- Ubuntu and Ubuntu-based distributions
- Debian and Debian-based distributions
- Arch Linux and derivatives (CachyOS, EndeavourOS, etc.)

## Development Conventions

### Coding Style

- Written in bash following POSIX compliance where possible
- Uses `set -e` for error handling
- Includes detailed comments in Portuguese (Brazilian)
- Modular function design for different installation methods

### Testing Practices

- Distribution detection validation
- Package existence checks before installation attempts
- Error code checking for AUR installations

### Contribution Guidelines

- Add new packages to the appropriate array (`PACOTES`, `AUR_PACOTES`, or `APPIMAGE`)
- Maintain alphabetical or logical ordering within arrays
- Ensure packages are available in the target repositories
- Test on multiple distribution families when possible

## Project Structure

- `install.sh`: Main automation script
- `README.md`: Comprehensive project documentation (this file)

## Additional Notes

- The script automatically installs `yay` if not present on Arch-based systems
- Package lists can be modified to suit individual needs
- The script provides detailed installation reports, including skipped packages
- Includes automatic setup of Flathub repository for Flatpak applications
