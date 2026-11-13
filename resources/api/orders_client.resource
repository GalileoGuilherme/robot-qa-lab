*** Settings ***
Documentation    API Client Keywords for /api/orders Service Endpoint.
Resource         api_common.resource

*** Variables ***
${ORDERS_SCHEMA_PATH}    ${CURDIR}/../../data/schemas/orders_schema.json

*** Keywords ***
Post Order
    [Arguments]    ${payload}
    [Documentation]    Sends POST request to /api/orders with the provided payload.
    ${response}=    POST On Session    alias=${API_SESSION}    url=/orders    json=${payload}    expected_status=any
    RETURN    ${response}

Validate Order Contract
    [Arguments]    ${response}
    [Documentation]    Validates that the response conforms to the Order Response JSON schema.
    Validate Json Schema    ${response.json()}    ${ORDERS_SCHEMA_PATH}

Assert Order Successful
    [Arguments]    ${response}
    [Documentation]    Verifies that the order was created (HTTP 201) and has a valid ID and CONFIRMED status.
    Assert HTTP Status Should Be    ${response}    201
    ${json}=    Set Variable    ${response.json()}
    Should Be True    ${json['success']}
    Dictionary Should Contain Key    ${json['order']}    id
    Should Start With    ${json['order']['id']}    ORD-
    Should Be Equal As Strings    ${json['order']['status']}    CONFIRMED
