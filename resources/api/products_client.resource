*** Settings ***
Documentation    API Client Keywords for /api/products Service Endpoint.
Resource         api_common.resource

*** Variables ***
${PRODUCTS_SCHEMA_PATH}    ${CURDIR}/../../data/schemas/products_schema.json

*** Keywords ***
Get All Products
    [Documentation]    Sends GET request to /api/products and returns the response.
    ${response}=    GET On Session    alias=${API_SESSION}    url=/products    expected_status=any
    RETURN    ${response}

Get Products By Category
    [Arguments]    ${category_name}
    [Documentation]    Sends GET request with category query parameter.
    ${params}=    Create Dictionary    category=${category_name}
    ${response}=    GET On Session    alias=${API_SESSION}    url=/products    params=${params}    expected_status=any
    RETURN    ${response}

Validate Products Contract
    [Arguments]    ${response}
    [Documentation]    Validates that the response conforms to the Products List JSON schema.
    Validate Json Schema    ${response.json()}    ${PRODUCTS_SCHEMA_PATH}

Assert Product Exists In Catalog
    [Arguments]    ${response}    ${expected_product_id}
    [Documentation]    Verifies that a product with the specified ID exists in the list.
    ${json}=    Set Variable    ${response.json()}
    ${found}=    Set Variable    ${False}
    FOR    ${item}    IN    @{json['products']}
        IF    '${item['id']}' == '${expected_product_id}'
            ${found}=    Set Variable    ${True}
            BREAK
        END
    END
    Should Be True    ${found}    msg=Product '${expected_product_id}' was not found in catalog.
