*** Settings ***
Documentation    Native iOS Mobile Test Suite using Appium XCUITest & iOS Screen Objects.
...              Executes on iOS Simulators (iPhone 15 Pro, iOS 17) and SauceLabs/BrowserStack iOS real devices.
Resource         ../../resources/mobile/screens/ios_swaglabs_screens.resource
Suite Setup      Global Suite Setup    Mobile iOS Automation
Suite Teardown   Global Suite Teardown
Test Setup       Start iOS App Session
Test Teardown    Close Mobile App Session
Test Tags        mobile    ios    xcuitest    native

*** Test Cases ***
Scenario: iOS Mobile Login With Valid Standard User
    [Documentation]    Authenticates on iPhone 15 Pro (iOS 17) using XCUITest and verifies catalog.
    [Tags]    smoke    critical    ios-smoke
    Fill iOS Login Credentials    standard_user    secret_sauce
    Tap iOS Login Button
    Verify iOS Catalog Screen Loaded

Scenario: iOS Mobile Login Error Message On Locked Out User
    [Documentation]    Verifies that locked_out_user displays native iOS error banner.
    [Tags]    negative    validation
    Fill iOS Login Credentials    locked_out_user    secret_sauce
    Tap iOS Login Button
    Verify iOS Login Error Displayed    Sorry, this user has been locked out.

Scenario: iOS Mobile Add Product To Cart And Proceed To Checkout
    [Documentation]    Adds item to cart on iOS device and advances to checkout screen.
    [Tags]    e2e    checkout    ios-e2e
    Fill iOS Login Credentials    standard_user    secret_sauce
    Tap iOS Login Button
    Verify iOS Catalog Screen Loaded
    Add First iOS Product To Cart
    Tap iOS Cart Badge
    Fill iOS Checkout Details    Galileo    Guilherme    51020-010
