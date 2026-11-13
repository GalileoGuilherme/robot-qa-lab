*** Settings ***
Documentation    Mobile Base Keywords for Appium Automation and Device Management (Android & iOS).
Resource         ../base.resource
Library          AppiumLibrary    run_on_failure=No Operation
Library          ../../libraries/MobileGestures.py

*** Variables ***
${APPIUM_SERVER_URL}      http://127.0.0.1:4723

# Android Defaults
${PLATFORM_NAME}          Android
${DEVICE_NAME}            Android Emulator
${APP_PACKAGE}            com.swaglabsmobileapp
${APP_ACTIVITY}           com.swaglabsmobileapp.MainActivity
${AUTOMATION_NAME}        UiAutomator2

# iOS Defaults
${IOS_PLATFORM_NAME}      iOS
${IOS_DEVICE_NAME}        iPhone 15 Pro
${IOS_PLATFORM_VERSION}   17.2
${IOS_BUNDLE_ID}          com.saucelabs.SwagLabsMobileApp
${IOS_AUTOMATION_NAME}    XCUITest

*** Keywords ***
Start Mobile App Session
    [Arguments]    ${platform}=${PLATFORM_NAME}    ${device}=${DEVICE_NAME}
    [Documentation]    Opens an Android Appium session. If Appium is not reachable locally, gracefully marks test as skipped.
    ${is_active}=    Check Appium Server Status    ${APPIUM_SERVER_URL}
    IF    not ${is_active}
        Skip    Appium Server is offline at ${APPIUM_SERVER_URL}. Skipping native Android device test (Simulated in CI/Cloud matrix).
    END
    Open Application    ${APPIUM_SERVER_URL}
    ...    platformName=${platform}
    ...    automationName=${AUTOMATION_NAME}
    ...    deviceName=${device}
    ...    appPackage=${APP_PACKAGE}
    ...    appActivity=${APP_ACTIVITY}
    ...    newCommandTimeout=120
    ...    autoGrantPermissions=${True}

Start iOS App Session
    [Arguments]    ${device}=${IOS_DEVICE_NAME}    ${platform_version}=${IOS_PLATFORM_VERSION}
    [Documentation]    Opens an iOS XCUITest session on Simulator or real iPhone. Gracefully skips if node is offline.
    ${is_active}=    Check Appium Server Status    ${APPIUM_SERVER_URL}
    IF    not ${is_active}
        Skip    Appium XCUITest Server is offline at ${APPIUM_SERVER_URL}. Skipping native iOS device test (Simulated in CI/Cloud matrix).
    END
    Open Application    ${APPIUM_SERVER_URL}
    ...    platformName=${IOS_PLATFORM_NAME}
    ...    automationName=${IOS_AUTOMATION_NAME}
    ...    deviceName=${device}
    ...    platformVersion=${platform_version}
    ...    bundleId=${IOS_BUNDLE_ID}
    ...    newCommandTimeout=120
    ...    autoAcceptAlerts=${True}

Close Mobile App Session
    [Documentation]    Closes the active mobile application.
    Run Keyword And Ignore Error    Close Application
