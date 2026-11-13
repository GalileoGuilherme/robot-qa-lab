*** Settings ***
Documentation    Web E2E Cross-Device Responsive Matrix Test Suite.
...              Validates Desktop (1280px), Tablet (768px), and Mobile (390px) Viewport Ergonomics and Layout Stability.
Resource         ../../resources/web/pages/home_page.resource
Resource         ../../resources/web/pages/automation_page.resource
Suite Setup      Global Suite Setup    Responsive Cross-Device
Suite Teardown   Global Suite Teardown
Test Tags        web    responsive    cross-device

*** Test Cases ***
Scenario: Desktop Viewport Layout Ergonomics (1280x800)
    [Documentation]    Validates layout on desktop: navigation links are expanded and no horizontal overflow occurs.
    [Tags]    desktop
    Start Web Session    width=1280    height=800
    Go To    ${BASE_URL}
    Verify Home Page Loaded
    # Assert horizontal scrollbar does not exist
    ${overflow}=    Evaluate JavaScript    ${None}    () => document.documentElement.scrollWidth > window.innerWidth
    Should Not Be True    ${overflow}    msg=Horizontal overflow detected on Desktop viewport!
    End Web Session

Scenario: Tablet Viewport Layout Ergonomics (768x1024 - iPad)
    [Documentation]    Validates layout on tablet portrait: elements wrap naturally without crushing.
    [Tags]    tablet
    Start Web Session    width=768    height=1024
    Go To    ${BASE_URL}
    Verify Home Page Loaded
    ${overflow}=    Evaluate JavaScript    ${None}    () => document.documentElement.scrollWidth > window.innerWidth
    Should Not Be True    ${overflow}    msg=Horizontal overflow detected on Tablet viewport!
    End Web Session

Scenario: Mobile Viewport Layout And Touch Ergonomics (390x844 - iPhone)
    [Documentation]    Validates mobile viewport with touch enabled: checks no horizontal overflow and accessibility touch sizing.
    [Tags]    mobile-web    touch
    Start Mobile Web Session    device_name=iPhone 14    width=390    height=844
    Go To    ${BASE_URL}
    ${overflow}=    Evaluate JavaScript    ${None}    () => document.documentElement.scrollWidth > window.innerWidth
    Should Not Be True    ${overflow}    msg=Horizontal overflow detected on Mobile viewport!
    End Web Session
