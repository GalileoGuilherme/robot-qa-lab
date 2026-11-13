*** Settings ***
Documentation    Mobile Screen Object for SwagLabs iOS Application (iPhone / iPad).
...              Uses iOS Predicate Strings and iOS Class Chains for maximum performance with XCUITest.
Resource         ../mobile_common.resource

*** Variables ***
# iOS Login Screen Locators
${IOS_LOGIN_USERNAME}       predicate=name == "test-Username"
${IOS_LOGIN_PASSWORD}       predicate=name == "test-Password"
${IOS_LOGIN_BUTTON}         predicate=name == "test-LOGIN"
${IOS_LOGIN_ERROR}          predicate=name == "test-Error message"

# iOS Catalog Screen Locators
${IOS_PRODUCTS_HEADER}      class_chain=**/XCUIElementTypeStaticText[`label == "PRODUCTS"`]
${IOS_FIRST_ADD_TO_CART}    xpath=(//XCUIElementTypeOther[@name="test-ADD TO CART"])[1]
${IOS_CART_BADGE}           accessibility_id=test-Cart

# iOS Checkout Locators
${IOS_CHECKOUT_FIRSTNAME}   accessibility_id=test-First Name
${IOS_CHECKOUT_LASTNAME}    accessibility_id=test-Last Name
${IOS_CHECKOUT_POSTALCODE}  accessibility_id=test-Zip/Postal Code
${IOS_CHECKOUT_CONTINUE}    accessibility_id=test-CONTINUE

*** Keywords ***
Fill iOS Login Credentials
    [Arguments]    ${username}    ${password}
    [Documentation]    Inputs credentials using iOS XCUITest text input.
    Wait Until Element Is Visible    ${IOS_LOGIN_USERNAME}    timeout=15s
    Input Text                       ${IOS_LOGIN_USERNAME}    ${username}
    Input Text                       ${IOS_LOGIN_PASSWORD}    ${password}

Tap iOS Login Button
    [Documentation]    Taps Login on iOS interface.
    Click Element    ${IOS_LOGIN_BUTTON}

Verify iOS Login Error Displayed
    [Arguments]    ${expected_message}
    [Documentation]    Asserts iOS native error banner contains expected text.
    Wait Until Element Is Visible    ${IOS_LOGIN_ERROR}    timeout=5s
    Element Should Contain Text      ${IOS_LOGIN_ERROR}    ${expected_message}

Verify iOS Catalog Screen Loaded
    [Documentation]    Validates that PRODUCTS header is visible on iOS view.
    Wait Until Element Is Visible    ${IOS_PRODUCTS_HEADER}    timeout=15s

Add First iOS Product To Cart
    [Documentation]    Taps first visible Add to Cart button on iOS.
    Wait Until Element Is Visible    ${IOS_FIRST_ADD_TO_CART}    timeout=5s
    Click Element                    ${IOS_FIRST_ADD_TO_CART}

Tap iOS Cart Badge
    [Documentation]    Taps cart icon on iOS navigation bar.
    Click Element    ${IOS_CART_BADGE}

Fill iOS Checkout Details
    [Arguments]    ${first_name}    ${last_name}    ${zip_code}
    [Documentation]    Fills customer info on iOS checkout view.
    Wait Until Element Is Visible    ${IOS_CHECKOUT_FIRSTNAME}    timeout=10s
    Input Text    ${IOS_CHECKOUT_FIRSTNAME}     ${first_name}
    Input Text    ${IOS_CHECKOUT_LASTNAME}      ${last_name}
    Input Text    ${IOS_CHECKOUT_POSTALCODE}    ${zip_code}
    Click Element    ${IOS_CHECKOUT_CONTINUE}
