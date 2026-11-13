*** Settings ***
Documentation    Page Object for Portfolio Home Page (https://portfolio-omega-six-18.vercel.app).
Resource         ../web_common.resource

*** Variables ***
${HOME_NAV_BRAND}           css=a[href="/"] >> nth=0
${HOME_NAV_AUTOMATION}      css=a[href="/automation"] >> nth=0
${HOME_HERO_TITLE}          css=h1 >> nth=0
${HOME_THEME_TOGGLE}        css=button[aria-label*="tema"], button[aria-label*="theme"], button[title*="tema"] >> nth=0
${HOME_CONTACT_SECTION}     id=contact, css=section[id="contato"] >> nth=0

*** Keywords ***
Navigate To Home Page
    [Documentation]    Opens the portfolio main landing page.
    Go To    ${BASE_URL}
    Wait For Elements State    ${HOME_HERO_TITLE}    visible    timeout=10s

Verify Home Page Loaded
    [Documentation]    Verifies key branding and navigation elements are present.
    Get Text    ${HOME_HERO_TITLE}    validate    value != ""
    Get Element States    ${HOME_NAV_AUTOMATION}    contains    attached

Navigate To Automation Lab
    [Documentation]    Clicks the Automation Lab link from navigation.
    Click    ${HOME_NAV_AUTOMATION}
    Wait For Elements State    id=qa-login-email    visible    timeout=15s
