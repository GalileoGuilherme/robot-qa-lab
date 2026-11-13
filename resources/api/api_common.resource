*** Settings ***
Documentation    Common Keywords and Sessions for Backend REST API Testing.
Resource         ../base.resource
Library          RequestsLibrary
Library          Collections
Library          ../../libraries/JsonSchemaValidator.py
Library          ../../libraries/PerformanceTelemetry.py

*** Variables ***
${API_SESSION}    qa_api_session

*** Keywords ***
Create API Client Session
    [Documentation]    Instantiates a persistent HTTP session for the target API environment.
    ${headers}=    Create Dictionary
    ...    Content-Type=application/json
    ...    Accept=application/json
    ...    User-Agent=RobotFramework-QALab/1.0
    Create Session    alias=${API_SESSION}    url=${API_BASE_URL}    headers=${headers}    verify=True

Assert HTTP Status Should Be
    [Arguments]    ${response}    ${expected_status}
    [Documentation]    Validates HTTP status code against expected integer.
    Should Be Equal As Integers    ${response.status_code}    ${expected_status}
    ...    msg=Expected HTTP status ${expected_status} but received ${response.status_code}

Assert Response Header
    [Arguments]    ${response}    ${header_name}    ${expected_value}
    [Documentation]    Verifies that a specific response header contains or matches the expected value.
    Dictionary Should Contain Key    ${response.headers}    ${header_name}
    Should Contain    ${response.headers['${header_name}']}    ${expected_value}

Assert Response SLA
    [Arguments]    ${response}    ${max_latency_ms}=${SLA_API_MAX_MS}
    [Documentation]    Asserts that response elapsed time is strictly within acceptable SLA.
    ${elapsed_ms}=    Evaluate    round(${response.elapsed.total_seconds()} * 1000, 2)
    Log    Response time: ${elapsed_ms} ms (SLA Limit: ${max_latency_ms} ms)
    Should Be True    ${elapsed_ms} <= ${max_latency_ms}
    ...    msg=SLA Breach: Response took ${elapsed_ms} ms, exceeding threshold of ${max_latency_ms} ms
