#!/usr/bin/env python3

#             _                 _           _        _ _
#  _ ____   _(_)_ __ ___       (_)_ __  ___| |_ __ _| | | ___ _ __ _ __  _   _
# | '_ \ \ / / | '_ ` _ \ _____| | '_ \/ __| __/ _` | | |/ _ \ '__| '_ \| | | |
# | | | \ V /| | | | | | |_____| | | | \__ \ || (_| | | |  __/ | _| |_) | |_| |
# |_| |_|\_/ |_|_| |_| |_|     |_|_| |_|___/\__\__,_|_|_|\___|_|(_) .__/ \__, |
#                                                                 |_|    |___/

# Parse the arguments first, so that we don't have to interpret
# the whole program before potentially failing.

import argparse
from pathlib import Path
from dataclasses import dataclass
from typing import Optional


@dataclass(frozen=True)
class Args:
    force: bool
    install_dir: Path
    symlink: Path
    repo: str

    @staticmethod
    def parse() -> "Args":
        parser = argparse.ArgumentParser(
            description="Install or Upgrade Neovim from GitHub Releases"
        )

        parser.add_argument(
            "-f",
            "--force",
            action="store_true",
            help="Force reinstall even if version matches",
        )

        parser.add_argument(
            "-i",
            "--install-dir",
            type=Path,
            default=Path("/opt/nvim"),
            help="Directory to unpack the files (Default: /opt/nvim)",
        )

        parser.add_argument(
            "-s",
            "--symlink",
            type=Path,
            default=Path("/usr/local/bin/nvim"),
            help="Location to create the executable symlink (Default: /usr/local/bin/nvim)",
        )

        parser.add_argument(
            "-r",
            "--repo",
            default="neovim/neovim",
            help="GitHub repository to fetch from (Default: neovim/neovim)",
        )

        args = parser.parse_args()
        return Args(
            force=args.force,
            install_dir=args.install_dir,
            symlink=args.symlink,
            repo=args.repo,
        )


if __name__ == "__main__":
    global args
    args = Args.parse()

import sys  # noqa: E402
import os  # noqa: E402
import platform  # noqa: E402
import subprocess  # noqa: E402
import urllib.request  # noqa: E402
import json  # noqa: E402
import tarfile  # noqa: E402
import tempfile  # noqa: E402
import enum  # noqa: E402
import shutil  # noqa: E402
from typing import Never  # noqa: E402


class TerminalColor(str, enum.Enum):
    GREEN = "\033[0;32m"
    BLUE = "\033[0;34m"
    YELLOW = "\033[1;33m"
    RED = "\033[0;31m"
    NC = "\033[0m"


def log(msg, color=TerminalColor.NC):
    print(f"{color}{msg}{TerminalColor.NC}")


def panic(msg) -> Never:
    print(f"{TerminalColor.RED}Error: {msg}{TerminalColor.NC}", file=sys.stderr)
    sys.exit(1)


def run_command(cmd: list) -> Optional[str]:
    """Run a command and return stdout string. Return None on failure."""
    try:
        result = subprocess.run(
            cmd,
            check=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
        )
        return result.stdout.strip()
    except subprocess.CalledProcessError:
        return None


def exec_cmd(cmd_list):
    """Runs a command directly (we are root). Converts Paths to strings."""
    cmd_str = [str(c) for c in cmd_list]
    subprocess.check_call(cmd_str)


def get_latest_tag(repo):
    """Fetches the latest tag name from GitHub API."""
    url = f"https://api.github.com/repos/{repo}/releases/latest"
    try:
        with urllib.request.urlopen(url) as response:
            data = json.loads(response.read().decode())
            return data.get("tag_name")
    except Exception as e:
        panic(f"Could not fetch info from GitHub API: {e}")


def get_local_version(binary_path: Path):
    """Gets version of the specifically targetted binary (e.g. v0.10.0) or None."""
    if not binary_path.exists():
        return None

    output = run_command([str(binary_path), "--version"])
    if output:
        first_line = output.splitlines()[0]
        parts = first_line.split()
        if len(parts) >= 2:
            return parts[1]
    return None


def get_asset_name():
    """Determines the correct asset name for the current OS/Arch."""
    system = platform.system().lower()  # linux, darwin
    machine = platform.machine().lower()  # x86_64, aarch64, arm64

    if system == "linux":
        os_tag = "linux"
    elif system == "darwin":
        os_tag = "macos"
    else:
        panic(f"Unsupported OS: {system}")

    if machine == "x86_64":
        arch_tag = "x86_64"
    elif machine in ("aarch64", "arm64"):
        arch_tag = "arm64"
    else:
        panic(f"Unsupported Architecture: {machine}")

    return f"nvim-{os_tag}-{arch_tag}.tar.gz"


def main():
    if os.geteuid() != 0:
        log("Not running as root. Attempting to elevate...", TerminalColor.YELLOW)
        try:
            cmd = ["sudo", sys.executable] + sys.argv
            subprocess.check_call(cmd)
        except subprocess.CalledProcessError as e:
            sys.exit(e.returncode)
        sys.exit(0)

    log(f"Checking for latest version in {args.repo}...", TerminalColor.BLUE)

    latest_tag = get_latest_tag(args.repo)
    log(f"Latest GitHub release: {latest_tag}", TerminalColor.GREEN)

    local_version = get_local_version(args.symlink)

    if local_version:
        log(f"Currently installed:   {local_version}", TerminalColor.YELLOW)
        if local_version == latest_tag and not args.force:
            log(
                f"You are already on the latest version at {args.symlink}! Exiting.",
                TerminalColor.GREEN,
            )
            return
        elif local_version == latest_tag and args.force:
            log(
                "Versions match, but --force flag used. Reinstalling...",
                TerminalColor.YELLOW,
            )
        else:
            log("New version available. Upgrading...", TerminalColor.BLUE)
    else:
        log(f"Neovim not found at {args.symlink}. Installing...", TerminalColor.YELLOW)

    asset_name = get_asset_name()
    download_url = (
        f"https://github.com/{args.repo}/releases/latest/download/{asset_name}"
    )

    with tempfile.TemporaryDirectory() as temp_dir_str:
        temp_dir = Path(temp_dir_str)

        log(f"Downloading and extracting {asset_name}...", TerminalColor.BLUE)

        try:
            with urllib.request.urlopen(download_url) as response:
                with tarfile.open(fileobj=response, mode="r|gz") as tar:
                    tar.extractall(path=temp_dir)
        except Exception as e:
            panic(f"Download or Extraction failed: {e}")

        try:
            extracted_dir = next(
                item
                for item in temp_dir.iterdir()
                if item.is_dir() and "nvim" in item.name
            )
        except StopIteration:
            panic("Could not find extracted directory structure.")

        log(f"Installing to {args.install_dir}...", TerminalColor.BLUE)

        if args.install_dir.exists():
            shutil.rmtree(args.install_dir)

        if not args.install_dir.parent.exists():
            args.install_dir.parent.mkdir(parents=True, exist_ok=True)

        shutil.move(str(extracted_dir), str(args.install_dir))

        log(f"Updating symlink at {args.symlink}...", TerminalColor.BLUE)
        if args.symlink.exists() or args.symlink.is_symlink():
            args.symlink.unlink()

        target_bin = args.install_dir / "bin" / "nvim"
        args.symlink.symlink_to(target_bin)

    log("Success! Installed version:", TerminalColor.GREEN)
    subprocess.run([str(args.symlink), "--version"], check=False)


if __name__ == "__main__":
    main()
