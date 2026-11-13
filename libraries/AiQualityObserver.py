"""
Robot Framework Library for Autonomous AI Quality Telemetry and Executive Reporting.
Bridges Robot Framework executions with Google Gemini AI and Local SDET Diagnostics.
"""

from robot.api import logger
from scripts.ai_qa_observer import run_observer, parse_robot_output_xml, generate_ai_insights


class AiQualityObserver:
    """Robot Framework Library for AI-powered Quality Observability and Report Dispatching."""

    ROBOT_LIBRARY_SCOPE = "GLOBAL"

    def generate_ai_quality_report(self, send_email: bool = False):
        """
        Executes AI Quality Observer, analyzes test results from output.xml,
        and generates executive_email_report.html with optional SMTP email dispatch.
        """
        logger.info("Executing Autonomous AI Quality Observer...")
        report_path = run_observer(send_email=send_email)
        logger.info(f"Executive Email Report generated at: {report_path}")
        return str(report_path)

    def analyze_execution_health(self):
        """
        Evaluates test statistics and returns AI assessment string.
        """
        stats = parse_robot_output_xml()
        ai_text, engine = generate_ai_insights(stats)
        logger.info(f"Health assessed by engine: {engine}")
        return {"insights": ai_text, "engine": engine, "stats": stats}
