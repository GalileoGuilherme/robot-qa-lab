*** Settings ***
Documentation    Mobile Base Keywords for Appium Automation and Device Management.
Resource         ../base.resource
Library          AppiumLibrary    run_on_failure=No Operation
Library          ../../libraries/MobileGestures.py

*** Variables ***
${APPIUM_SERVER_URL}      http://127.0.0.1:4723
${PLATFORM_NAME}          Android
${DEVICE_NAME}            Android Emulator
${APP_PACKAGE}            com.swaglabsmobileapp
${APP_ACTIVITY}           com.swaglabsmobileapp.MainActivity
${AUTOMATION_NAME}        UiAutomator2
${APP_SAMPLE_URL}         https://github.com/saucelabs/sample-app-mobile/releases/download/2.7.1/Android.SauceLabs.Mobile.Sample.app.2.7.1.apk

*** Keywords ***
Start Mobile App Session
    [Arguments]    ${platform}=${PLATFORM_NAME}    ${device}=${DEVICE_NAME}    ${app}=${None}
    [Documentation]    Opens an Appium session. If Appium is not reachable locally, gracefully marks test as skipped.
    ${is_active}=    Check Appium Server Status    ${APPIUM_SERVER_URL}
    IF    not ${is_active}
        Skip    Appium Server is offline at ${APPIUM_SERVER_URL}. Skipping native mobile device test (Simulated in CI/Cloud matrix).
    END
    Open Application    ${APPIUM_SERVER_URL}
    ...    platformName=${platform}
    ...    automationName=${AUTOMATION_NAME}
    ...    deviceName=${device}
    ...    appPackage=${APP_PACKAGE}
    ...    appActivity=${APP_ACTIVITY}
    ...    newCommandTimeout=120
    ...    autoGrantPermissions=${True}

Close Mobile App Session
    [Documentation]    Closes the active mobile application.
    Run Keyword And Ignore Error    Close Application
