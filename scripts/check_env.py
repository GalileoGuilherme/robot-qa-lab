"""
Environment Diagnostics and Healthcheck Script for Robot QA Lab.
"""

import shutil
import subprocess
import sys
from pathlib import Path


def check_status(name: str, check_fn) -> bool:
    try:
        ok, msg = check_fn()
        status_icon = "✅" if ok else "⚠️"
        print(f" {status_icon} {name:<30} {msg}")
        return ok
    except Exception as e:
        print(f" ❌ {name:<30} Error during verification: {e}")
        return False


def check_python():
    version = f"{sys.version_info.major}.{sys.version_info.minor}.{sys.version_info.micro}"
    return (sys.version_info >= (3, 10)), f"v{version} (Python 3.10+ required)"


def check_robot():
    try:
        import robot
        return True, f"v{robot.__version__}"
    except ImportError:
        return False, "Not installed (pip install -r requirements.txt)"


def check_browser_lib():
    try:
        import Browser
        return True, f"v{Browser.__version__} (Playwright Engine)"
    except ImportError:
        return False, "Not installed (pip install robotframework-browser && rfbrowser init)"


def check_node():
    node = shutil.which("node")
    if not node:
        return False, "Node.js not detected in PATH (Required for rfbrowser init)"
    res = subprocess.run(["node", "--version"], capture_output=True, text=True)
    return True, res.stdout.strip()


def check_appium():
    import urllib.request
    try:
        with urllib.request.urlopen("http://127.0.0.1:4723/status", timeout=2) as resp:
            return True, f"Active (HTTP {resp.status})"
    except Exception:
        return False, "Offline (Optional for local emulation; tests gracefully skip)"


def main():
    print("\n" + "=" * 70)
    print("🔍 ROBOT QA LAB - ENVIRONMENT DIAGNOSTICS & SYSTEM AUDIT")
    print("=" * 70)
    check_status("Python Runtime", check_python)
    check_status("Robot Framework Engine", check_robot)
    check_status("Browser Library (Playwright)", check_browser_lib)
    check_status("Node.js Runtime", check_node)
    check_status("Appium Server (Port 4723)", check_appium)
    print("=" * 70 + "\n")


if __name__ == "__main__":
    main()
