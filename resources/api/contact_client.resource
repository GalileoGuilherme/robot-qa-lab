*** Settings ***
Documentation    API Client Keywords for /api/contact Service Endpoint.
Resource         api_common.resource

*** Variables ***
${CONTACT_SCHEMA_PATH}    ${CURDIR}/../../data/schemas/contact_schema.json

*** Keywords ***
Post Contact Message
    [Arguments]    ${payload}
    [Documentation]    Sends POST request to /api/contact with message payload.
    ${response}=    POST On Session    alias=${API_SESSION}    url=/contact    json=${payload}    expected_status=any
    RETURN    ${response}

Validate Contact Contract
    [Arguments]    ${response}
    [Documentation]    Validates that the response conforms to the Contact JSON schema.
    Validate Json Schema    ${response.json()}    ${CONTACT_SCHEMA_PATH}
