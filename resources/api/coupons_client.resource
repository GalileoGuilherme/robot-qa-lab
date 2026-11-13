*** Settings ***
Documentation    API Client Keywords for /api/coupons Endpoints.
Resource         api_common.resource

*** Variables ***
${COUPON_SCHEMA_PATH}    ${CURDIR}/../../data/schemas/coupon_schema.json

*** Keywords ***
Validate Coupon Code
    [Arguments]    ${coupon_code}
    [Documentation]    Sends POST request to /api/coupons/validate with code.
    ${payload}=    Create Dictionary    code=${coupon_code}
    ${response}=   POST On Session      alias=${API_SESSION}    url=/coupons/validate    json=${payload}    expected_status=any
    RETURN    ${response}

Validate Coupon Contract
    [Arguments]    ${response}
    [Documentation]    Validates coupon response against schema.
    Validate Json Schema    ${response.json()}    ${COUPON_SCHEMA_PATH}
