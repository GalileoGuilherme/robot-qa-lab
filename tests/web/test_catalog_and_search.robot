*** Settings ***
Documentation    Web E2E Test Suite for Product Catalog, Search Debounce, and Categories Filtering.
Resource         ../../resources/web/pages/automation_page.resource
Suite Setup      Global Suite Setup    Web E2E Testing
Suite Teardown   Global Suite Teardown
Test Setup       Start Web Session
Test Teardown    End Web Session
Test Tags        web    catalog    e2e

*** Test Cases ***
Scenario: Authenticate Into Store And Verify Full Product Catalog
    [Documentation]    Logs into demo store and verifies product cards are displayed.
    [Tags]    smoke    critical
    Login To Automation Store
    ${count}=    Get Element Count    ${PRODUCT_LIST_ITEMS}
    Should Be True    ${count} >= 6    msg=Expected at least 6 products in catalog, got ${count}

Scenario: Search Product With Debounce Filter
    [Documentation]    Inputs search term 'Fone Bluetooth' and asserts catalog filters to single item.
    [Tags]    search
    Login To Automation Store
    Search Product    Fone Bluetooth
    Wait For Elements State    id=qa-product-fone-bluetooth    visible    timeout=5s
    ${count}=    Get Element Count    ${PRODUCT_LIST_ITEMS}
    Should Be Equal As Integers    ${count}    1

Scenario: Search With Non-Existent Query Shows Empty State
    [Documentation]    Searches for non-existent item and asserts empty state banner is displayed.
    [Tags]    search    empty-state
    Login To Automation Store
    Search Product    produto-inexistente-xyz
    Wait For Elements State    ${PRODUCT_EMPTY_STATE}    visible    timeout=5s

Scenario: Filter Products By Category
    [Documentation]    Filters catalog by 'Casa' and verifies visible items belong to category.
    [Tags]    filter
    Login To Automation Store
    Filter By Category    Casa
    Wait For Elements State    id=qa-product-lampada-smart    visible    timeout=5s
    ${count}=    Get Element Count    ${PRODUCT_LIST_ITEMS}
    Should Be Equal As Integers    ${count}    2

Scenario: Sort Products By Price Ascending And Descending
    [Documentation]    Sorts catalog by price ascending and price descending.
    [Tags]    sorting
    Login To Automation Store
    Sort Catalog By    price-ascending
    ${first_id_asc}=    Get Property    ${PRODUCT_LIST_ITEMS} >> nth=0    id
    Should Be Equal As Strings    ${first_id_asc}    qa-product-lampada-smart

    Sort Catalog By    price-descending
    ${first_id_desc}=   Get Property    ${PRODUCT_LIST_ITEMS} >> nth=0    id
    Should Be Equal As Strings    ${first_id_desc}    qa-product-teclado-mecanico
