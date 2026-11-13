"""
Unified Test Runner CLI for Robot QA Lab.
Orchestrates test suites across API, Web E2E, Mobile, and Performance layers.
"""

import argparse
import os
import subprocess
import sys
import time
from pathlib import Path

# Ensure project root is in sys.path
ROOT_DIR = Path(__file__).resolve().parent.parent
if str(ROOT_DIR) not in sys.path:
    sys.path.insert(0, str(ROOT_DIR))


def run_tests():
    parser = argparse.ArgumentParser(
        description="Unified Test Runner for Robot QA Lab Full-Stack Suite."
    )
    parser.add_argument(
        "--layer",
        "-l",
        choices=["all", "api", "web", "mobile", "performance", "smoke"],
        default="all",
        help="Test engineering layer to execute (default: all)",
    )
    parser.add_argument(
        "--tags",
        "-t",
        type=str,
        default=None,
        help="Robot Framework tags filter expression (e.g. 'smoke', 'contractORp95')",
    )
    parser.add_argument(
        "--browser",
        "-b",
        choices=["chromium", "firefox", "webkit"],
        default="chromium",
        help="Browser engine for web tests (default: chromium)",
    )
    parser.add_argument(
        "--headless",
        action="store_true",
        default=True,
        help="Run web tests in headless mode (default: True)",
    )
    parser.add_argument(
        "--headed",
        dest="headless",
        action="store_false",
        help="Run web tests with visible browser window",
    )
    parser.add_argument(
        "--env",
        "-e",
        choices=["production", "staging", "local"],
        default="production",
        help="Target test environment (default: production)",
    )
    parser.add_argument(
        "--metrics",
        "-m",
        action="store_true",
        default=True,
        help="Generate robotframework-metrics HTML dashboard upon test completion (default: True)",
    )
    parser.add_argument(
        "--outputdir",
        "-o",
        type=str,
        default="results",
        help="Output directory for reports and logs (default: results)",
    )

    args = parser.parse_args()
    results_dir = ROOT_DIR / args.outputdir
    results_dir.mkdir(parents=True, exist_ok=True)

    # Set environment variables for the execution
    os.environ["TEST_ENV"] = args.env
    os.environ["HEADLESS"] = "true" if args.headless else "false"
    os.environ["BROWSER"] = args.browser

    # Map target path according to layer
    if args.layer == "all":
        target_path = str(ROOT_DIR / "tests")
    elif args.layer == "api":
        target_path = str(ROOT_DIR / "tests" / "api")
    elif args.layer == "web":
        target_path = str(ROOT_DIR / "tests" / "web")
    elif args.layer == "mobile":
        target_path = str(ROOT_DIR / "tests" / "mobile")
    elif args.layer == "performance":
        target_path = str(ROOT_DIR / "tests" / "performance")
    elif args.layer == "smoke":
        target_path = str(ROOT_DIR / "tests")
        args.tags = "smoke"

    cmd = [
        sys.executable,
        "-m",
        "robot",
        "--outputdir",
        str(results_dir),
        "--variable",
        f"ENV:{args.env}",
        "--variable",
        f"BROWSER:{args.browser}",
        "--variable",
        f"HEADLESS:{args.headless}",
        "--loglevel",
        "INFO",
    ]

    if args.tags:
        cmd.extend(["--include", args.tags])

    cmd.append(target_path)

    print("\n" + "=" * 80)
    print("🚀 ROBOT QA LAB - UNIFIED AUTOMATION RUNNER")
    print("=" * 80)
    print(f" Layer:          {args.layer.upper()}")
    print(f" Environment:    {args.env.upper()}")
    print(f" Browser:        {args.browser} (Headless: {args.headless})")
    print(f" Tags Filter:    {args.tags or 'ALL'}")
    print(f" Target Path:    {target_path}")
    print(f" Results Dir:    {results_dir}")
    print("=" * 80 + "\n")

    start_time = time.time()
    result = subprocess.run(cmd)
    duration = round(time.time() - start_time, 2)

    print("\n" + "-" * 80)
    print(f" Execution completed in {duration} seconds with Return Code: {result.returncode}")
    print(f" Native Log:     file:///{results_dir / 'log.html'}")
    print(f" Native Report:  file:///{results_dir / 'report.html'}")

    if args.metrics and (results_dir / "output.xml").exists():
        print("-" * 80)
        try:
            from scripts.generate_metrics import generate_metrics
            generate_metrics()
            print(f" Executive Dashboard: file:///{results_dir / 'metrics.html'}")
        except Exception as e:
            print(f"Warning: Could not generate metrics dashboard: {e}")

    print("=" * 80 + "\n")
    sys.exit(result.returncode)


if __name__ == "__main__":
    run_tests()
