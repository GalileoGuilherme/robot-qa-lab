"""
Generates executive visual metrics dashboard from Robot Framework output.xml.
"""

import sys
from pathlib import Path
from robotframework_metrics.runner import parse_options, generate_report


def generate_metrics():
    root = Path(__file__).resolve().parent.parent
    results_dir = root / "results"
    output_xml = results_dir / "output.xml"

    if not output_xml.exists():
        print(f"[ERROR] Output XML file not found at: {output_xml}")
        print("Please execute tests first before generating metrics.")
        sys.exit(1)

    print(f"Generating Executive HTML Metrics Dashboard from {output_xml}...")
    sys.argv = [
        "robotmetrics",
        "-I",
        str(results_dir),
        "-M",
        "metrics.html",
    ]

    try:
        args = parse_options()
        generate_report(args)
        metrics_file = results_dir / "metrics.html"
        print(f"[SUCCESS] Metrics report created at: {metrics_file}")
    except Exception as e:
        print(f"[ERROR] Failed to generate metrics: {e}")
        sys.exit(1)


if __name__ == "__main__":
    generate_metrics()
