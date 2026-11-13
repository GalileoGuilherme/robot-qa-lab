*** Settings ***
Documentation    Native Mobile Test Suite using AppiumLibrary & Screen Object Pattern.
...              Validates SwagLabs Mobile Demo APK (com.swaglabsmobileapp) on Android / iOS.
...              Executes seamlessly on Local Appium 2.x, SauceLabs, or BrowserStack cloud matrix.
Resource         ../../resources/mobile/screens/swaglabs_login_screen.resource
Resource         ../../resources/mobile/screens/swaglabs_catalog_screen.resource
Resource         ../../resources/mobile/screens/swaglabs_checkout_screen.resource
Suite Setup      Global Suite Setup    Mobile Appium Automation
Suite Teardown   Global Suite Teardown
Test Setup       Start Mobile App Session
Test Teardown    Close Mobile App Session
Test Tags        mobile    appium    native

*** Test Cases ***
Scenario: Mobile Login With Valid Standard User
    [Documentation]    Authenticates into native app using standard_user and verifies catalog loads.
    [Tags]    smoke    critical
    Fill Mobile Login Credentials    standard_user    secret_sauce
    Tap Login Button
    Verify Catalog Screen Loaded

Scenario: Mobile Login Error Message On Locked Out User
    [Documentation]    Attempts login with locked_out_user and validates native error banner.
    [Tags]    negative    validation
    Fill Mobile Login Credentials    locked_out_user    secret_sauce
    Tap Login Button
    Verify Mobile Login Error Displayed    Sorry, this user has been locked out.

Scenario: Mobile Add Product To Cart And Proceed To Checkout
    [Documentation]    Navigates native catalog, adds first item, opens cart, and verifies checkout form.
    [Tags]    e2e    checkout
    Fill Mobile Login Credentials    standard_user    secret_sauce
    Tap Login Button
    Verify Catalog Screen Loaded
    Add First Product To Cart
    Tap Cart Icon
    Fill Mobile Customer Details    Galileo    Guilherme    51020-010
