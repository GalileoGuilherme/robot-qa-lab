*** Settings ***
Documentation    Performance and Latency SLA Benchmarking Suite for Backend REST APIs.
...              Executes multi-iteration benchmarks, captures latency percentiles (P50, P90, P95),
...              and validates strict performance budgets.
Resource         ../../resources/performance/performance_keywords.resource
Suite Setup      Global Suite Setup    Performance SLA Benchmarks
Suite Teardown   Global Suite Teardown
Test Tags        performance    sla    benchmark

*** Test Cases ***
Scenario: Benchmark Healthcheck Endpoint Under Strict Latency SLA
    [Documentation]    Runs 8 iterations against /api/health and validates P95 < 900ms and Max < 1500ms.
    [Tags]    critical    p95
    ${summary}=    Benchmark Endpoint Under SLA
    ...    endpoint_path=/health
    ...    method=GET
    ...    iterations=8
    ...    sla_p95=900.0
    ...    sla_max=1500.0
    Should Be True    ${summary['avg_ms']} > 0
    Log    Benchmarked /api/health - P95: ${summary['p95_ms']} ms, Avg: ${summary['avg_ms']} ms    console=True

Scenario: Benchmark Products Catalog Under Production Load SLA
    [Documentation]    Runs 5 iterations against /api/products and validates P95 < 1200ms.
    [Tags]    catalog    p95
    ${summary}=    Benchmark Endpoint Under SLA
    ...    endpoint_path=/products
    ...    method=GET
    ...    iterations=5
    ...    sla_p95=1200.0
    ...    sla_max=2000.0
    Should Be True    ${summary['p95_ms']} <= 1200.0
    Log    Benchmarked /api/products - P95: ${summary['p95_ms']} ms, Avg: ${summary['avg_ms']} ms    console=True

Scenario: Verify API Throughput Stability And Latency Jitter
    [Documentation]    Verifies that the delta between minimum and maximum response times is stable.
    [Tags]    jitter    stability
    ${summary}=    Verify API Throughput Stability    endpoint_path=/health    iterations=6
    ${jitter}=     Evaluate    round(${summary['max_ms']} - ${summary['min_ms']}, 2)
    Log    API Jitter: ${jitter} ms (Min: ${summary['min_ms']} ms, Max: ${summary['max_ms']} ms)    console=True

Scenario: Enforce API Response Payload Size Budget Under 100 KB
    [Documentation]    Ensures response size does not exceed payload transfer budget.
    [Tags]    payload    budget
    ${summary}=    Benchmark Endpoint Under SLA
    ...    endpoint_path=/products
    ...    method=GET
    ...    iterations=2
    ...    sla_p95=1500.0
    ...    sla_max=2500.0
    Should Be True    ${summary['avg_payload_kb']} < 100.0    msg=Products payload exceeded 100KB budget!
    Log    Products Payload Size: ${summary['avg_payload_kb']} KB (Budget: < 100 KB)    console=True
