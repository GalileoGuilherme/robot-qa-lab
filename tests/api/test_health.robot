*** Settings ***
Documentation    Backend REST API Test Suite for /api/health Service.
...              Validates OpenAPI 3.0.3 contract compliance, service status, and latency SLA.
Resource         ../../resources/api/health_client.resource
Suite Setup      Run Keywords    Global Suite Setup    API Testing
...              AND             Create API Client Session
Suite Teardown   Global Suite Teardown
Test Tags        api    health    smoke

*** Test Cases ***
Scenario: Healthcheck Returns Status UP And Conforms To Contract
    [Documentation]    Verifies that GET /api/health returns HTTP 200 with status UP and valid OpenAPI schema.
    [Tags]    contract    critical
    ${response}=    Get Health Status
    Assert HTTP Status Should Be    ${response}    200
    Validate Health Contract        ${response}
    ${json}=    Set Variable        ${response.json()}
    Should Be Equal As Strings      ${json['status']}         UP
    Should Be Equal As Strings      ${json['service']}        qa-portfolio-api
    Should Be Equal As Strings      ${json['environment']}    production

Scenario: Healthcheck Meets Performance Latency SLA
    [Documentation]    Verifies that GET /api/health responds within strict SLA threshold (< 800ms).
    [Tags]    sla    performance
    ${response}=    Get Health Status
    Assert HTTP Status Should Be    ${response}    200
    Assert Response SLA             ${response}    max_latency_ms=800

Scenario: Healthcheck Service Responds With JSON Content-Type
    [Documentation]    Verifies response headers include application/json.
    [Tags]    headers
    ${response}=    Get Health Status
    Assert Response Header          ${response}    Content-Type    application/json
