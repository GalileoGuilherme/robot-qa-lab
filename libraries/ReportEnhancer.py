"""
Report Enhancer and Listener for Robot Framework
Appends suite execution metadata, environment variables, and telemetry headers.
"""

from robot.libraries.BuiltIn import BuiltIn
from robot.api import logger
import platform
import os


class ReportEnhancer:
    """Robot Framework Library for enriching HTML reports with telemetry metadata."""

    ROBOT_LIBRARY_SCOPE = "GLOBAL"

    def inject_suite_metadata(self, test_layer: str):
        """
        Injects rich runtime metadata into Robot Framework log.html and report.html.
        """
        builtin = BuiltIn()
        builtin.set_suite_metadata("Test Engineering Layer", test_layer)
        builtin.set_suite_metadata("Operating System", f"{platform.system()} {platform.release()} ({platform.machine()})")
        builtin.set_suite_metadata("Python Runtime", platform.python_version())
        builtin.set_suite_metadata("Target Environment", os.getenv("TEST_ENV", "production"))
        builtin.set_suite_metadata("Automation Architecture", "Robot Framework + Playwright Browser + Requests + Appium")
        logger.info(f"Report Metadata Injected for Layer: {test_layer}")
