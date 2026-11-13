"""
Performance Telemetry and SLA Validation Library for Robot Framework
Provides lightweight API latency benchmarking and Web Core Web Vitals / Navigation Timing audits.
"""

import math
import time
from typing import Any, Dict, List, Optional
import requests
from robot.api import logger


class PerformanceTelemetry:
    """Robot Framework Library for lightweight performance telemetry and SLA threshold assertions."""

    ROBOT_LIBRARY_SCOPE = "GLOBAL"

    @staticmethod
    def _percentile(values: List[float], percent: float) -> float:
        if not values:
            return 0.0
        sorted_values = sorted(values)
        k = (len(sorted_values) - 1) * (percent / 100.0)
        f = math.floor(k)
        c = math.ceil(k)
        if f == c:
            return sorted_values[int(k)]
        d0 = sorted_values[int(f)] * (c - k)
        d1 = sorted_values[int(c)] * (k - f)
        return round(d0 + d1, 2)

    def benchmark_api_endpoint(
        self,
        url: str,
        method: str = "GET",
        iterations: int = 5,
        headers: Optional[Dict[str, str]] = None,
        json_payload: Optional[Dict[str, Any]] = None,
        sla_p95_ms: float = 1000.0,
        sla_max_ms: float = 1500.0,
    ) -> Dict[str, Any]:
        """
        Executes an endpoint `iterations` times, measures latencies using high-resolution timers,
        computes statistical distribution (min, max, avg, median, p95), and validates against SLA thresholds.
        """
        headers = headers or {}
        latencies: List[float] = []
        status_codes: List[int] = []
        payload_sizes: List[int] = []

        logger.info(f"Starting API Benchmark: {method} {url} ({iterations} iterations, SLA P95: {sla_p95_ms}ms)")

        session = requests.Session()
        for i in range(1, iterations + 1):
            start = time.perf_counter()
            resp = session.request(
                method=method.upper(),
                url=url,
                headers=headers,
                json=json_payload,
                timeout=15,
            )
            elapsed_ms = round((time.perf_counter() - start) * 1000.0, 2)
            latencies.append(elapsed_ms)
            status_codes.append(resp.status_code)
            payload_sizes.append(len(resp.content))
            logger.debug(f"  Iteration {i}/{iterations}: status={resp.status_code}, latency={elapsed_ms}ms, size={len(resp.content)} bytes")

        min_lat = min(latencies)
        max_lat = max(latencies)
        avg_lat = round(sum(latencies) / len(latencies), 2)
        med_lat = self._percentile(latencies, 50)
        p90_lat = self._percentile(latencies, 90)
        p95_lat = self._percentile(latencies, 95)
        avg_size_kb = round(sum(payload_sizes) / len(payload_sizes) / 1024.0, 2)

        summary = {
            "url": url,
            "method": method.upper(),
            "iterations": iterations,
            "min_ms": min_lat,
            "max_ms": max_lat,
            "avg_ms": avg_lat,
            "median_ms": med_lat,
            "p90_ms": p90_lat,
            "p95_ms": p95_lat,
            "avg_payload_kb": avg_size_kb,
            "status_codes": list(set(status_codes)),
        }

        # Format executive HTML log
        html_table = f"""
        <div style="background:#0f172a; color:#f8fafc; padding:12px; border-radius:8px; font-family:monospace; margin:8px 0;">
            <b style="color:#38bdf8;">⚡ API SLA BENCHMARK SUMMARY:</b> {method.upper()} {url}<br/>
            --------------------------------------------------------------------------------<br/>
            Iterations: <b>{iterations}</b> | Status Codes: <b>{summary['status_codes']}</b> | Avg Payload: <b>{avg_size_kb} KB</b><br/>
            Min Latency: <b style="color:#4ade80;">{min_lat} ms</b> | Median (p50): <b>{med_lat} ms</b><br/>
            Average: <b>{avg_lat} ms</b> | P90: <b>{p90_lat} ms</b> | P95: <b style="color:#fbbf24;">{p95_lat} ms</b> | Max: <b style="color:#f87171;">{max_lat} ms</b><br/>
            Target SLA P95: <b>{sla_p95_ms} ms</b> | Target SLA Max: <b>{sla_max_ms} ms</b>
        </div>
        """
        logger.info(html_table, html=True)

        if p95_lat > sla_p95_ms:
            raise AssertionError(
                f"SLA Violation: P95 Latency ({p95_lat} ms) exceeded SLA threshold ({sla_p95_ms} ms) for {url}"
            )
        if max_lat > sla_max_ms:
            raise AssertionError(
                f"SLA Violation: Max Latency ({max_lat} ms) exceeded maximum threshold ({sla_max_ms} ms) for {url}"
            )

        return summary

    def evaluate_web_navigation_timing(
        self,
        nav_entry: Dict[str, Any],
        sla_ttfb_ms: float = 800.0,
        sla_dom_interactive_ms: float = 2500.0,
        sla_load_ms: float = 4000.0,
    ) -> Dict[str, float]:
        """
        Calculates Web Performance metrics using Navigation Timing API Level 2:
        - TTFB (Time to First Byte): responseStart - requestStart
        - DOM Interactive: domInteractive - responseEnd
        - DOM Content Loaded: domContentLoadedEventEnd - fetchStart
        - Full Load Time: loadEventEnd - fetchStart (or responseEnd if load incomplete)
        """
        fetch_start = float(nav_entry.get("fetchStart", 0))
        req_start = float(nav_entry.get("requestStart", fetch_start))
        resp_start = float(nav_entry.get("responseStart", req_start))
        resp_end = float(nav_entry.get("responseEnd", resp_start))
        dom_interactive = float(nav_entry.get("domInteractive", resp_end))
        dom_content_loaded = float(nav_entry.get("domContentLoadedEventEnd", dom_interactive))
        load_end = float(nav_entry.get("loadEventEnd", dom_content_loaded))
        transfer_size = float(nav_entry.get("transferSize", 0))

        # Metrics in milliseconds
        ttfb = max(0.0, round(resp_start - req_start, 2))
        dom_interactive_time = max(0.0, round(dom_interactive - fetch_start, 2))
        dom_content_loaded_time = max(0.0, round(dom_content_loaded - fetch_start, 2))
        full_load_time = max(0.0, round(load_end - fetch_start, 2))
        transfer_kb = round(transfer_size / 1024.0, 2)

        results = {
            "ttfb_ms": ttfb,
            "dom_interactive_ms": dom_interactive_time,
            "dom_content_loaded_ms": dom_content_loaded_time,
            "full_load_ms": full_load_time,
            "transfer_kb": transfer_kb,
        }

        html_table = f"""
        <div style="background:#0f172a; color:#f8fafc; padding:12px; border-radius:8px; font-family:monospace; margin:8px 0;">
            <b style="color:#a855f7;">🌐 WEB NAVIGATION TIMING TELEMETRY (W3C Standard):</b><br/>
            --------------------------------------------------------------------------------<br/>
            TTFB (Time to First Byte): <b style="color:#38bdf8;">{ttfb} ms</b> (SLA: &lt; {sla_ttfb_ms} ms)<br/>
            DOM Interactive: <b style="color:#4ade80;">{dom_interactive_time} ms</b> (SLA: &lt; {sla_dom_interactive_ms} ms)<br/>
            DOM Content Loaded: <b>{dom_content_loaded_time} ms</b><br/>
            Full Load Event: <b style="color:#fbbf24;">{full_load_time} ms</b> (SLA: &lt; {sla_load_ms} ms)<br/>
            Total Transfer Size: <b>{transfer_kb} KB</b>
        </div>
        """
        logger.info(html_table, html=True)

        # Assert SLAs
        if ttfb > sla_ttfb_ms:
            raise AssertionError(f"Web Performance SLA Breach: TTFB ({ttfb} ms) > SLA ({sla_ttfb_ms} ms)")
        if dom_interactive_time > sla_dom_interactive_ms:
            raise AssertionError(
                f"Web Performance SLA Breach: DOM Interactive ({dom_interactive_time} ms) > SLA ({sla_dom_interactive_ms} ms)"
            )
        if full_load_time > sla_load_ms:
            raise AssertionError(
                f"Web Performance SLA Breach: Full Load Time ({full_load_time} ms) > SLA ({sla_load_ms} ms)"
            )

        return results
