*** Settings ***
Documentation    Backend REST API Test Suite for /api/orders Service.
...              Validates order checkout, schema contract, coupon discounts, and order IDs.
Resource         ../../resources/api/orders_client.resource
Suite Setup      Run Keywords    Global Suite Setup    API Testing
...              AND             Create API Client Session
Suite Teardown   Global Suite Teardown
Test Tags        api    orders    checkout

*** Keywords ***
Create Sample Order Item
    [Arguments]    ${id}=fone-bluetooth    ${name}=Fone Bluetooth    ${price}=${199.9}    ${quantity}=${1}
    ${item}=    Create Dictionary    id=${id}    name=${name}    price=${price}    quantity=${quantity}
    RETURN    ${item}

*** Test Cases ***
Scenario: Create Valid Order And Validate OpenAPI Contract
    [Documentation]    Submits a valid order and validates response schema, ID format (ORD-XXXX), and CONFIRMED status.
    [Tags]    contract    smoke    critical
    ${item}=        Create Sample Order Item
    ${items_list}=  Create List    ${item}
    ${payload}=     Create Dictionary
    ...    customerName=Galileo Guilherme SDET
    ...    customerEmail=galileo.qa@example.com
    ...    address=Rua dos Testes, 42 - Recife, PE
    ...    shippingMethod=Padrão grátis
    ...    shippingPrice=${0}
    ...    discount=${0}
    ...    items=${items_list}
    ${response}=    Post Order    ${payload}
    Assert Order Successful       ${response}
    Validate Order Contract       ${response}

Scenario: Reject Order With Empty Items List
    [Documentation]    Verifies that the API enforces business rule: cart cannot be empty (HTTP 400).
    [Tags]    negative    validation
    ${empty_items}=    Create List
    ${payload}=        Create Dictionary
    ...    customerName=Galileo Guilherme
    ...    address=Rua dos Testes, 42
    ...    items=${empty_items}
    ${response}=    Post Order    ${payload}
    Assert HTTP Status Should Be    ${response}    400
    ${json}=        Set Variable    ${response.json()}
    Should Not Be True              ${json['success']}
    Should Contain                  ${json['error']}    Adicione ao menos um produto

Scenario: Order Service Performance Latency SLA
    [Documentation]    Validates that order placement fulfills SLA threshold (< 1200ms).
    [Tags]    sla    performance
    ${item}=        Create Sample Order Item
    ${items_list}=  Create List    ${item}
    ${payload}=     Create Dictionary
    ...    customerName=Benchmark Runner
    ...    customerEmail=bench@qa.com
    ...    address=Rua SLA, 1
    ...    items=${items_list}
    ${response}=    Post Order    ${payload}
    Assert HTTP Status Should Be    ${response}    201
    Assert Response SLA             ${response}    max_latency_ms=1200
