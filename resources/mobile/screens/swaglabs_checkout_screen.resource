*** Settings ***
Documentation    Mobile Screen Object for Swag Labs Mobile Checkout.
Resource         ../mobile_common.resource

*** Variables ***
${CHECKOUT_FIRSTNAME}     accessibility_id=test-First Name
${CHECKOUT_LASTNAME}      accessibility_id=test-Last Name
${CHECKOUT_POSTALCODE}    accessibility_id=test-Zip/Postal Code
${CHECKOUT_CONTINUE_BTN}  accessibility_id=test-CONTINUE
${CHECKOUT_FINISH_BTN}    accessibility_id=test-FINISH
${CHECKOUT_SUCCESS_TEXT}  xpath=//android.widget.TextView[@text="THANK YOU FOR YOU ORDER"]

*** Keywords ***
Fill Mobile Customer Details
    [Arguments]    ${firstname}    ${lastname}    ${postalcode}
    [Documentation]    Inputs native checkout fields.
    Wait Until Element Is Visible    ${CHECKOUT_FIRSTNAME}    timeout=10s
    Input Text    ${CHECKOUT_FIRSTNAME}     ${firstname}
    Input Text    ${CHECKOUT_LASTNAME}      ${lastname}
    Input Text    ${CHECKOUT_POSTALCODE}    ${postalcode}
    Click Element    ${CHECKOUT_CONTINUE_BTN}

Finish Mobile Order
    [Documentation]    Scrolls to finish button and clicks.
    Scroll Down Until Element Visible    ${CHECKOUT_FINISH_BTN}
    Click Element    ${CHECKOUT_FINISH_BTN}
