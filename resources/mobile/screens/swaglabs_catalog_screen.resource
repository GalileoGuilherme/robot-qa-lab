*** Settings ***
Documentation    Mobile Screen Object for Swag Labs Product Catalog Screen.
Resource         ../mobile_common.resource

*** Variables ***
${PRODUCTS_HEADER}         xpath=//android.widget.TextView[@text="PRODUCTS"]
${FIRST_ITEM_TITLE}        xpath=(//android.widget.TextView[@content-desc="test-Item title"])[1]
${FIRST_ADD_TO_CART_BTN}   xpath=(//android.view.ViewGroup[@content-desc="test-ADD TO CART"])[1]
${CART_ICON_BADGE}         accessibility_id=test-Cart
${FILTER_BUTTON}           accessibility_id=test-Modal Selector Button

*** Keywords ***
Verify Catalog Screen Loaded
    [Documentation]    Validates that native products header is displayed.
    Wait Until Element Is Visible    ${PRODUCTS_HEADER}    timeout=15s

Add First Product To Cart
    [Documentation]    Taps on the first visible Add to Cart button.
    Wait Until Element Is Visible    ${FIRST_ADD_TO_CART_BTN}    timeout=5s
    Click Element                    ${FIRST_ADD_TO_CART_BTN}

Tap Cart Icon
    [Documentation]    Navigates to cart view.
    Click Element    ${CART_ICON_BADGE}
