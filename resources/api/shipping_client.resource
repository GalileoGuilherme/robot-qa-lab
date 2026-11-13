*** Settings ***
Documentation    API Client Keywords for /api/shipping Endpoints.
Resource         api_common.resource

*** Variables ***
${SHIPPING_SCHEMA_PATH}    ${CURDIR}/../../data/schemas/shipping_schema.json

*** Keywords ***
Calculate Shipping For CEP
    [Arguments]    ${cep}=51020-010
    [Documentation]    Sends POST request to /api/shipping/calculate with target CEP.
    ${payload}=    Create Dictionary    cep=${cep}
    ${response}=   POST On Session      alias=${API_SESSION}    url=/shipping/calculate    json=${payload}    expected_status=any
    RETURN    ${response}

Validate Shipping Contract
    [Arguments]    ${response}
    [Documentation]    Validates shipping response against schema.
    Validate Json Schema    ${response.json()}    ${SHIPPING_SCHEMA_PATH}
