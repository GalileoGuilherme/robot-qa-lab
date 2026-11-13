*** Settings ***
Documentation    Backend REST API Test Suite for /api/products Service.
...              Validates catalog retrieval, categories filtering, data integrity, and OpenAPI contract.
Resource         ../../resources/api/products_client.resource
Suite Setup      Run Keywords    Global Suite Setup    API Testing
...              AND             Create API Client Session
Suite Teardown   Global Suite Teardown
Test Tags        api    products    catalog

*** Test Cases ***
Scenario: Retrieve All Products And Validate OpenAPI Contract
    [Documentation]    Fetches entire catalog and validates schema, item count, and required fields.
    [Tags]    contract    smoke
    ${response}=    GetAll Products
    Assert HTTP Status Should Be    ${response}    200
    Validate Products Contract      ${response}
    ${json}=    Set Variable        ${response.json()}
    Should Be True                  ${json['success']}
    Should Be True                  ${json['total']} > 0
    Assert Product Exists In Catalog    ${response}    fone-bluetooth
    Assert Product Exists In Catalog    ${response}    teclado-mecanico

Scenario: Filter Products By Category Electronics
    [Documentation]    Queries products by category 'Eletrônicos' and asserts all returned items belong to it.
    [Tags]    filter
    ${response}=    Get Products By Category    Eletrônicos
    Assert HTTP Status Should Be    ${response}    200
    Validate Products Contract      ${response}
    ${json}=    Set Variable        ${response.json()}
    FOR    ${item}    IN    @{json['products']}
        Should Be Equal As Strings    ${item['category']}    Eletrônicos
    END

Scenario: Filter Products By Category Home
    [Documentation]    Queries products by category 'Casa' and asserts category filter accuracy.
    [Tags]    filter
    ${response}=    Get Products By Category    Casa
    Assert HTTP Status Should Be    ${response}    200
    Validate Products Contract      ${response}
    ${json}=    Set Variable        ${response.json()}
    FOR    ${item}    IN    @{json['products']}
        Should Be Equal As Strings    ${item['category']}    Casa
    END

Scenario: Products Business Data Integrity Checks
    [Documentation]    Validates that stock is non-negative, price > 0, and ratings are between 0 and 5.
    [Tags]    integrity    regression
    ${response}=    GetAll Products
    ${json}=        Set Variable    ${response.json()}
    FOR    ${item}    IN    @{json['products']}
        Should Be True    ${item['price']} > 0        msg=Product ${item['id']} has invalid price
        Should Be True    ${item['stock']} >= 0       msg=Product ${item['id']} has negative stock
        Should Be True    0 <= ${item['rating']} <= 5    msg=Product ${item['id']} has invalid rating
    END

Scenario: Products Catalog Meets Latency SLA
    [Documentation]    Validates that the full catalog endpoint responds within SLA (< 1000ms).
    [Tags]    sla    performance
    ${response}=    GetAll Products
    Assert HTTP Status Should Be    ${response}    200
    Assert Response SLA             ${response}    max_latency_ms=1000
