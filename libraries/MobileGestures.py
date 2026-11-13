"""
Mobile Gestures and Device Utility Library for Robot Framework
Provides touch gestures, viewport scrolling, and Appium server health diagnostics.
"""

import time
import requests
from typing import Optional
from robot.libraries.BuiltIn import BuiltIn
from robot.api import logger


class MobileGestures:
    """Robot Framework Library for advanced mobile interactions and gesture automation."""

    ROBOT_LIBRARY_SCOPE = "GLOBAL"

    def __init__(self):
        pass

    @property
    def _appium(self):
        try:
            return BuiltIn().get_library_instance("AppiumLibrary")
        except Exception:
            return None

    def check_appium_server_status(self, server_url: str = "http://127.0.0.1:4723") -> bool:
        """
        Pings the Appium status endpoint (/status) to verify if the server is active.
        Returns True if Appium 2.x is reachable, False otherwise.
        """
        status_url = f"{server_url.rstrip('/')}/status"
        try:
            resp = requests.get(status_url, timeout=3)
            if resp.status_code == 200:
                data = resp.json()
                is_ready = data.get("value", {}).get("ready", True)
                logger.info(f"Appium Server active at {server_url}. Ready={is_ready}")
                return True
        except Exception as e:
            logger.debug(f"Appium server ping failed at {status_url}: {e}")
        return False

    def swipe_by_percent(
        self,
        start_x_pct: float,
        start_y_pct: float,
        end_x_pct: float,
        end_y_pct: float,
        duration_ms: int = 800,
    ):
        """
        Performs a touch swipe using screen percentage coordinates (0.0 to 1.0).
        Works consistently across device screen resolutions and aspect ratios.
        """
        appium = self._appium
        if not appium:
            raise RuntimeError("AppiumLibrary is not loaded in this suite context.")

        width = appium.get_window_width()
        height = appium.get_window_height()

        start_x = int(width * (start_x_pct / 100.0))
        start_y = int(height * (start_y_pct / 100.0))
        end_x = int(width * (end_x_pct / 100.0))
        end_y = int(height * (end_y_pct / 100.0))

        logger.info(f"Swiping from ({start_x}, {start_y}) to ({end_x}, {end_y}) over {duration_ms}ms")
        appium.swipe(start_x, start_y, end_x, end_y, duration_ms)

    def scroll_down_until_element_visible(self, locator: str, max_swipes: int = 6):
        """
        Repeatedly swipes up (scrolling down) until `locator` becomes visible or `max_swipes` is reached.
        """
        appium = self._appium
        if not appium:
            raise RuntimeError("AppiumLibrary is not loaded in this suite context.")

        for attempt in range(1, max_swipes + 1):
            is_visible = appium._is_element_present(locator) and appium._is_visible(locator)
            if is_visible:
                logger.info(f"Element '{locator}' found on swipe attempt #{attempt}")
                return True

            logger.info(f"Element '{locator}' not visible yet. Scrolling down... (attempt {attempt}/{max_swipes})")
            # Swipe from 80% to 20% vertically in middle of screen
            self.swipe_by_percent(50, 80, 50, 20, 700)
            time.sleep(0.5)

        raise AssertionError(f"Element '{locator}' was not found after {max_swipes} scroll attempts.")
