*** Settings ***
Documentation    Page Object for Checkout and Order Finalization.
Resource         ../web_common.resource

*** Variables ***
${CHECKOUT_ADDRESS_INPUT}    id=qa-checkout-address
${CHECKOUT_TERMS_CHECKBOX}   id=qa-terms
${CHECKOUT_SUBMIT_BTN}       id=qa-checkout-submit
${CHECKOUT_GUIDANCE_MSG}     id=qa-checkout-guidance
${ORDER_CONFIRMATION_BOX}    id=qa-order-confirmation
${ORDER_NUMBER_LABEL}        id=qa-order-number

*** Keywords ***
Fill Delivery Address
    [Arguments]    ${address}
    [Documentation]    Types address into delivery input.
    Fill Text    ${CHECKOUT_ADDRESS_INPUT}    ${address}

Accept Terms And Conditions
    [Documentation]    Checks terms and conditions checkbox.
    Check Checkbox    ${CHECKOUT_TERMS_CHECKBOX}

Submit Checkout Order
    [Documentation]    Clicks submit order button.
    Click    ${CHECKOUT_SUBMIT_BTN}

Verify Order Confirmation Displayed
    [Documentation]    Asserts that order confirmation is visible and returns generated order ID.
    Wait For Elements State    ${ORDER_CONFIRMATION_BOX}    visible    timeout=10s
    ${order_id}=    Get Text    ${ORDER_NUMBER_LABEL}
    Should Match Regexp    ${order_id}    ^QA-\\d+$
    RETURN    ${order_id}

Verify Submit Button Is Disabled
    [Documentation]    Asserts that checkout submit button is in disabled state.
    Get Element States    ${CHECKOUT_SUBMIT_BTN}    contains    disabled
