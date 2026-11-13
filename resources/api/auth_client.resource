*** Settings ***
Documentation    API Client Keywords for /api/auth Endpoints.
Resource         api_common.resource

*** Variables ***
${AUTH_SCHEMA_PATH}    ${CURDIR}/../../data/schemas/auth_schema.json

*** Keywords ***
Login With API
    [Arguments]    ${email}=qa@exemplo.com    ${password}=LabQA!Run-7kV2pX9m
    [Documentation]    Authenticates against /api/auth/login and returns response.
    ${payload}=    Create Dictionary    email=${email}    password=${password}
    ${response}=   POST On Session      alias=${API_SESSION}    url=/auth/login    json=${payload}    expected_status=any
    RETURN    ${response}

Validate Auth Contract
    [Arguments]    ${response}
    [Documentation]    Validates auth response against OpenAPI schema.
    Validate Json Schema    ${response.json()}    ${AUTH_SCHEMA_PATH}
