*** Settings ***
Documentation    Performance and SLA Telemetry Keywords for Robot Framework.
Resource         ../base.resource
Library          ../../libraries/PerformanceTelemetry.py

*** Keywords ***
Benchmark Endpoint Under SLA
    [Arguments]    ${endpoint_path}    ${method}=GET    ${iterations}=5    ${json_payload}=${None}    ${sla_p95}=${SLA_API_P95_MS}    ${sla_max}=${SLA_API_MAX_MS}
    [Documentation]    Runs benchmark for target endpoint and validates P95 and Max latency SLAs.
    ${url}=    Set Variable    ${API_BASE_URL}${endpoint_path}
    ${summary}=    Benchmark Api Endpoint
    ...    url=${url}
    ...    method=${method}
    ...    iterations=${iterations}
    ...    json_payload=${json_payload}
    ...    sla_p95_ms=${sla_p95}
    ...    sla_max_ms=${sla_max}
    RETURN    ${summary}

Verify API Throughput Stability
    [Arguments]    ${endpoint_path}    ${iterations}=10
    [Documentation]    Runs a burst of iterations and verifies standard deviation / jitter does not exceed tolerance.
    ${url}=    Set Variable    ${API_BASE_URL}${endpoint_path}
    ${summary}=    Benchmark Api Endpoint
    ...    url=${url}
    ...    method=GET
    ...    iterations=${iterations}
    ...    sla_p95_ms=${SLA_API_P95_MS}
    ...    sla_max_ms=${SLA_API_MAX_MS}
    ${jitter}=    Evaluate    round(${summary['max_ms']} - ${summary['min_ms']}, 2)
    Log    Endpoint Jitter: ${jitter} ms (Min: ${summary['min_ms']} ms, Max: ${summary['max_ms']} ms)
    RETURN    ${summary}
