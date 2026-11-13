"""
Environment Configuration Loader for Robot Framework
Loads environment configurations dynamically based on the active target environment.
"""

import json
import os
from pathlib import Path


def get_project_root() -> Path:
    return Path(__file__).resolve().parent.parent


def get_variables(environment: str = None):
    """
    Called by Robot Framework when imported as a variable file:
    robot --variablefile config/env.py ...
    """
    config_path = get_project_root() / "config" / "default_env.json"
    with open(config_path, "r", encoding="utf-8") as f:
        data = json.load(f)

    target_env = (
        environment
        or os.getenv("TEST_ENV")
        or "production"
    ).lower()

    env_data = data["environments"].get(target_env, data["environments"]["production"])
    browser_data = data.get("browser", {})
    sla_data = data.get("performance_sla", {})

    # Allow CLI / Environment variable overrides
    headless_env = os.getenv("HEADLESS")
    headless = (headless_env.lower() in ("true", "1", "yes")) if headless_env else browser_data.get("headless", True)
    browser_type = os.getenv("BROWSER", browser_data.get("default_browser", "chromium"))

    variables = {
        "ENV": target_env,
        "BASE_URL": os.getenv("BASE_URL", env_data["base_url"]),
        "API_BASE_URL": os.getenv("API_BASE_URL", env_data["api_base_url"]),
        "TIMEOUT": env_data["timeout"],
        "API_TIMEOUT": env_data["api_timeout"],
        "BROWSER": browser_type,
        "HEADLESS": headless,
        "SLOWMO": browser_data.get("slow_mo", "0ms"),
        "VIEWPORT_WIDTH": browser_data.get("viewport", {}).get("width", 1280),
        "VIEWPORT_HEIGHT": browser_data.get("viewport", {}).get("height", 800),
        "SLA_API_MAX_MS": sla_data.get("api_max_response_time_ms", 1200),
        "SLA_API_P95_MS": sla_data.get("api_p95_response_time_ms", 900),
        "SLA_WEB_TTFB_MS": sla_data.get("web_max_ttfb_ms", 800),
        "SLA_WEB_DOM_INTERACTIVE_MS": sla_data.get("web_max_dom_interactive_ms", 2500),
        "SLA_WEB_LOAD_MS": sla_data.get("web_max_load_event_ms", 4000),
        "SLA_MAX_PAYLOAD_KB": sla_data.get("max_payload_kb", 100),
        "PROJECT_ROOT": str(get_project_root()),
    }

    return variables
