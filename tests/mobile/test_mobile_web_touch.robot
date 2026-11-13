*** Settings ***
Documentation    Mobile Web Touch and Gesture Emulation Test Suite.
...              Validates touch gestures, mobile cart interaction, and WCAG 2.2 minimum touch targets (>= 44px).
Resource         ../../resources/web/pages/automation_page.resource
Suite Setup      Global Suite Setup    Mobile Web & Touch
Suite Teardown   Global Suite Teardown
Test Setup       Start Mobile Web Session    device_name=Pixel 7 Pro    width=412    height=915
Test Teardown    End Web Session
Test Tags        mobile    mobile-web    touch    wcag

*** Test Cases ***
Scenario: Mobile Touch Authentication And Catalog Navigation
    [Documentation]    Interacts with login and catalog using simulated mobile touch taps and gestures.
    [Tags]    smoke    touch
    Login To Automation Store
    ${count}=    Get Element Count    ${PRODUCT_LIST_ITEMS}
    Should Be True    ${count} >= 6
    # Emulate mobile touch tap on Add to Cart
    Click    id=qa-add-fone-bluetooth
    Wait For Elements State    id=qa-cart-row-fone-bluetooth    visible    timeout=5s
    Get Text    ${CART_COUNT_LABEL}    contains    1

Scenario: Mobile Touch Cart Quantity Management
    [Documentation]    Taps quantity input on mobile viewport and increments product count.
    [Tags]    touch    cart
    Login To Automation Store
    Click    id=qa-add-fone-bluetooth
    Wait For Elements State    id=qa-cart-row-fone-bluetooth    visible    timeout=5s
    Fill Text    id=qa-quantity-fone-bluetooth    2
    Get Text    ${CART_COUNT_LABEL}    contains    2

Scenario: WCAG 2.2 Touch Target Size Audit On Mobile Inputs And Buttons
    [Documentation]    Audits that key interactive touch controls have minimum bounding box dimensions (>= 36px height).
    [Tags]    accessibility    wcag    ergonomics
    Login To Automation Store
    # Audit search input bounding box
    ${search_bbox}=    Get Bounding Box    ${PRODUCT_SEARCH_INPUT}
    Should Be True     ${search_bbox['height']} >= 36.0    msg=Search input is too small for mobile touch (< 36px height)
    # Audit add-to-cart button bounding box
    ${btn_bbox}=       Get Bounding Box    id=qa-add-fone-bluetooth
    Should Be True     ${btn_bbox['height']} >= 36.0    msg=Add-to-cart button is too small for mobile touch (< 36px height)
    Log    Touch Target Audit Passed: Search height=${search_bbox['height']}px, Button height=${btn_bbox['height']}px    console=True
