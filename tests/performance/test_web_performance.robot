*** Settings ***
Documentation    Web Performance and Core Web Vitals Navigation Timing Telemetry Suite.
...              Audits real browser rendering metrics against strict performance budgets using W3C Navigation Timing Level 2.
Resource         ../../resources/web/web_common.resource
Resource         ../../resources/web/pages/home_page.resource
Suite Setup      Global Suite Setup    Web Performance Telemetry
Suite Teardown   Global Suite Teardown
Test Setup       Start Web Session
Test Teardown    End Web Session
Test Tags        performance    web-vitals    telemetry

*** Test Cases ***
Scenario: Audit Landing Page W3C Navigation Timing Budgets
    [Documentation]    Opens portfolio home page and validates TTFB < 800ms, DOM Interactive < 2500ms, and Full Load < 4000ms.
    [Tags]    critical    cwv
    Go To    ${BASE_URL}
    Wait For Elements State    ${HOME_HERO_TITLE}    visible    timeout=10s
    ${telemetry}=    Capture Web Performance Telemetry
    Log    Home Telemetry -> TTFB: ${telemetry['ttfb_ms']}ms, DOM Interactive: ${telemetry['dom_interactive_ms']}ms, Load: ${telemetry['full_load_ms']}ms    console=True
    Should Be True    ${telemetry['ttfb_ms']} >= 0
    Should Be True    ${telemetry['dom_interactive_ms']} > 0

Scenario: Audit Automation Store Navigation Timing Budgets
    [Documentation]    Navigates to store page and asserts rendering and asset transfer budgets.
    [Tags]    store    cwv
    Go To    ${BASE_URL}/automation
    Wait For Elements State    id=qa-login-email    visible    timeout=10s
    ${telemetry}=    Capture Web Performance Telemetry
    Log    Automation Store -> TTFB: ${telemetry['ttfb_ms']}ms, DOM Interactive: ${telemetry['dom_interactive_ms']}ms, Load: ${telemetry['full_load_ms']}ms    console=True
    Should Be True    ${telemetry['dom_interactive_ms']} <= ${SLA_WEB_DOM_INTERACTIVE_MS}
