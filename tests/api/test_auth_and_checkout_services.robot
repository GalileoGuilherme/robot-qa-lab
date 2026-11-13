*** Settings ***
Documentation    Backend REST API Test Suite for Auth, Coupons, and Shipping Services.
...              Validates JWT generation, coupon discount rules, shipping calculations, and contract schemas.
Resource         ../../resources/api/auth_client.resource
Resource         ../../resources/api/coupons_client.resource
Resource         ../../resources/api/shipping_client.resource
Suite Setup      Run Keywords    Global Suite Setup    API Testing
...              AND             Create API Client Session
Suite Teardown   Global Suite Teardown
Test Tags        api    services

*** Test Cases ***
Scenario: Authenticate Demo User And Obtain JWT Token
    [Documentation]    Verifies that POST /api/auth/login returns HTTP 200, JWT token, and user payload.
    [Tags]    auth    smoke    critical
    ${response}=    Login With API    email=qa@exemplo.com    password=LabQA!Run-7kV2pX9m
    Assert HTTP Status Should Be      ${response}    200
    Validate Auth Contract            ${response}
    ${json}=        Set Variable      ${response.json()}
    Should Be True  ${json['success']}
    Should Not Be Empty               ${json['token']}
    Should Be Equal As Strings        ${json['user']['email']}    qa@exemplo.com
    Should Be Equal As Strings        ${json['user']['role']}     QA Engineer

Scenario: Validate Promo Coupon CYPRESS10 Returns 10 Percent Discount
    [Documentation]    Verifies that POST /api/coupons/validate accepts valid coupon CYPRESS10.
    [Tags]    coupons    business-rules
    ${response}=    Validate Coupon Code    CYPRESS10
    Assert HTTP Status Should Be            ${response}    200
    Validate Coupon Contract                ${response}
    ${json}=        Set Variable            ${response.json()}
    Should Be True                          ${json['valid']}
    Should Be Equal As Integers             ${json['discountPercent']}    10

Scenario: Reject Invalid Promo Coupon With Error Message
    [Documentation]    Verifies that an unknown coupon is rejected with HTTP 400.
    [Tags]    coupons    negative
    ${response}=    Validate Coupon Code    CUPOM_INVENTADO
    Assert HTTP Status Should Be            ${response}    400
    ${json}=        Set Variable            ${response.json()}
    Should Not Be True                      ${json['valid']}
    Should Contain                          ${json['error']}    inválido ou expirado

Scenario: Calculate Shipping Quotes For Valid CEP
    [Documentation]    Verifies that POST /api/shipping/calculate returns standard and express freight options.
    [Tags]    shipping    business-rules
    ${response}=    Calculate Shipping For CEP    51020-010
    Assert HTTP Status Should Be                  ${response}    200
    Validate Shipping Contract                    ${response}
    ${json}=        Set Variable                  ${response.json()}
    Should Be True  ${json['success']}
    ${methods}=     Set Variable                  ${json['methods']}
    Length Should Be    ${methods}    2
    # Verify free standard shipping exists
    ${free_found}=  Set Variable    ${False}
    FOR    ${m}    IN    @{methods}
        IF    ${m['price']} == 0
            ${free_found}=    Set Variable    ${True}
            BREAK
        END
    END
    Should Be True    ${free_found}    msg=Standard free shipping was not returned.
