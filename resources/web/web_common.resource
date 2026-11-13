*** Settings ***
Documentation    Common Web Keywords using Playwright Browser Library.
Resource         ../base.resource
Library          Browser
Library          ../../libraries/PerformanceTelemetry.py

*** Variables ***
${DEFAULT_DEVICE_WIDTH}     1280
${DEFAULT_DEVICE_HEIGHT}    800

*** Keywords ***
Start Web Session
    [Arguments]    ${url}=${BASE_URL}    ${headless}=${HEADLESS}    ${browser_type}=${BROWSER}    ${width}=${DEFAULT_DEVICE_WIDTH}    ${height}=${DEFAULT_DEVICE_HEIGHT}
    [Documentation]    Launches a modern Playwright browser instance and navigates to the target URL.
    New Browser    browser=${browser_type}    headless=${headless}    args=["--no-sandbox", "--disable-dev-shm-usage"]
    New Context    viewport={'width': ${width}, 'height': ${height}}    locale=pt-BR
    New Page       ${url}
    Set Browser Timeout    15s

Start Mobile Web Session
    [Arguments]    ${device_name}=Pixel 7    ${width}=412    ${height}=915
    [Documentation]    Emulates a mobile device viewport with touch capabilities enabled.
    New Browser    browser=chromium    headless=${HEADLESS}    args=["--no-sandbox"]
    New Context    viewport={'width': ${width}, 'height': ${height}}    isMobile=${True}    hasTouch=${True}    userAgent=Mozilla/5.0 (Linux; Android 13; ${device_name}) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36
    New Page       ${BASE_URL}
    Set Browser Timeout    15s

End Web Session
    [Documentation]    Closes the current browser context.
    Close Browser

Capture Web Performance Telemetry
    [Documentation]    Extracts W3C Navigation Timing API metrics via JavaScript evaluation and asserts performance SLAs.
    ${nav_metrics}=    Evaluate JavaScript    ${None}    () => JSON.parse(JSON.stringify(window.performance.getEntriesByType('navigation')[0] || window.performance.timing))
    ${results}=        Evaluate Web Navigation Timing    ${nav_metrics}    sla_ttfb_ms=${SLA_WEB_TTFB_MS}    sla_dom_interactive_ms=${SLA_WEB_DOM_INTERACTIVE_MS}    sla_load_ms=${SLA_WEB_LOAD_MS}
    RETURN    ${results}
