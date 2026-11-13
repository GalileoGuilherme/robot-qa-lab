*** Settings ***
Documentation    API Client Keywords for /api/health Service Endpoint.
Resource         api_common.resource

*** Variables ***
${HEALTH_SCHEMA_PATH}    ${CURDIR}/../../data/schemas/health_schema.json

*** Keywords ***
Get Health Status
    [Documentation]    Sends GET request to /api/health and returns the response.
    ${response}=    GET On Session    alias=${API_SESSION}    url=/health    expected_status=any
    RETURN    ${response}

Validate Health Contract
    [Arguments]    ${response}
    [Documentation]    Validates that the response conforms to the OpenAPI 3.0.3 Health JSON schema.
    Validate Json Schema    ${response.json()}    ${HEALTH_SCHEMA_PATH}
