*** Settings ***
Documentation    Web E2E Test Suite for Cart Management, Promo Discounts, and Full Checkout.
Resource         ../../resources/web/pages/automation_page.resource
Resource         ../../resources/web/pages/checkout_page.resource
Suite Setup      Global Suite Setup    Web E2E Testing
Suite Teardown   Global Suite Teardown
Test Setup       Start Web Session
Test Teardown    End Web Session
Test Tags        web    cart    checkout    e2e

*** Test Cases ***
Scenario: Add Product To Cart And Verify Counter
    [Documentation]    Adds 'Fone Bluetooth' to cart, asserts badge count and feedback notification.
    [Tags]    cart    smoke
    Login To Automation Store
    Add Product To Cart    fone-bluetooth
    Get Text    ${CART_COUNT_LABEL}    contains    1
    VerifyFeedback Message Contains     adicionado ao carrinho

Scenario: Change Product Quantity In Cart
    [Documentation]    Increases quantity of item in cart and asserts updated subtotal.
    [Tags]    cart    quantity
    Login To Automation Store
    Add Product To Cart    fone-bluetooth
    Change Cart Product Quantity    fone-bluetooth    2
    Get Text    ${CART_COUNT_LABEL}    contains    2

Scenario: Apply Valid Promo Code CYPRESS10
    [Documentation]    Applies promo code CYPRESS10 and verifies discount element appears.
    [Tags]    promo    coupon
    Login To Automation Store
    Add Product To Cart    fone-bluetooth
    Apply Promo Code       CYPRESS10
    Wait For Elements State    ${CART_DISCOUNT_LABEL}    visible    timeout=5s
    Get Text    ${CART_DISCOUNT_LABEL}    validate    value != ""

Scenario: Remove Product And Verify Empty Cart
    [Documentation]    Removes item from cart and validates empty cart placeholder.
    [Tags]    cart    empty
    Login To Automation Store
    Add Product To Cart    fone-bluetooth
    Remove Product From Cart    fone-bluetooth
    Verify Cart Empty State

Scenario: Validate Required Checkout Fields Enforce Disabled Submit
    [Documentation]    Attempts checkout without filling address or terms, verifying button remains disabled.
    [Tags]    checkout    validation
    Login To Automation Store
    Add Product To Cart    fone-bluetooth
    Verify Submit Button Is Disabled

Scenario: Complete Full Checkout Flow With Order Confirmation
    [Documentation]    Adds product, fills delivery address, accepts terms, submits order, and asserts QA confirmation number.
    [Tags]    checkout    critical    e2e
    Login To Automation Store
    Add Product To Cart    fone-bluetooth
    Fill Delivery Address    Rua dos Testes Automatizados, 100 - Recife, PE
    Accept Terms And Conditions
    Submit Checkout Order
    ${order_id}=    Verify Order Confirmation Displayed
    Log    Order successfully created with Confirmation ID: ${order_id}    console=True
