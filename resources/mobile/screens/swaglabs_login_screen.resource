*** Settings ***
Documentation    Mobile Screen Object for Swag Labs Login Screen.
Resource         ../mobile_common.resource

*** Variables ***
${LOGIN_USERNAME_FIELD}    accessibility_id=test-Username
${LOGIN_PASSWORD_FIELD}    accessibility_id=test-Password
${LOGIN_SUBMIT_BUTTON}     accessibility_id=test-LOGIN
${LOGIN_ERROR_MESSAGE}     accessibility_id=test-Error message

*** Keywords ***
Fill Mobile Login Credentials
    [Arguments]    ${username}    ${password}
    [Documentation]    Inputs username and password into native mobile inputs.
    Wait Until Element Is Visible    ${LOGIN_USERNAME_FIELD}    timeout=15s
    Input Text                       ${LOGIN_USERNAME_FIELD}    ${username}
    Input Text                       ${LOGIN_PASSWORD_FIELD}    ${password}

Tap Login Button
    [Documentation]    Taps on the mobile Login button.
    Click Element    ${LOGIN_SUBMIT_BUTTON}

Verify Mobile Login Error Displayed
    [Arguments]    ${expected_message}
    [Documentation]    Asserts that login error banner is displayed with expected text.
    Wait Until Element Is Visible    ${LOGIN_ERROR_MESSAGE}    timeout=5s
    Element Should Contain Text      ${LOGIN_ERROR_MESSAGE}    ${expected_message}
