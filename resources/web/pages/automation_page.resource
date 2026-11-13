*** Settings ***
Documentation    Page Object for QA Automation Lab Store (https://portfolio-omega-six-18.vercel.app/automation).
Resource         ../web_common.resource
Library          String

*** Variables ***
# Authentication Selectors
${LOGIN_EMAIL_INPUT}        id=qa-login-email
${LOGIN_PASSWORD_INPUT}     id=qa-login-password
${LOGIN_SUBMIT_BTN}         id=qa-login-submit

# Catalog Selectors
${PRODUCT_SEARCH_INPUT}     id=qa-product-search
${PRODUCT_LIST_ITEMS}       css=#qa-product-list > article
${PRODUCT_EMPTY_STATE}      id=qa-products-empty
${CATEGORY_FILTER_SELECT}   id=qa-category-filter
${SORT_PRODUCTS_SELECT}     id=qa-sort-products
${STORE_FEEDBACK_MSG}       id=qa-store-feedback

# Cart Selectors
${CART_COUNT_LABEL}         id=qa-cart-count
${CART_EMPTY_STATE}         id=qa-cart-empty
${CART_SUBTOTAL_LABEL}      id=qa-subtotal
${CART_DISCOUNT_LABEL}      id=qa-discount
${CART_TOTAL_LABEL}         id=qa-total
${PROMO_CODE_INPUT}         id=qa-promo-code
${APPLY_PROMO_BTN}          id=qa-apply-promo

*** Keywords ***
Login To Automation Store
    [Arguments]    ${email}=qa@exemplo.com    ${password}=LabQA!Run-7kV2pX9m
    [Documentation]    Navigates to /automation and performs standard demo login.
    Go To    ${BASE_URL}/automation
    Wait For Elements State    ${LOGIN_EMAIL_INPUT}    visible    timeout=15s
    Fill Text    ${LOGIN_EMAIL_INPUT}       ${email}
    Fill Text    ${LOGIN_PASSWORD_INPUT}    ${password}
    Click        ${LOGIN_SUBMIT_BTN}
    Wait For Elements State    ${PRODUCT_SEARCH_INPUT}    visible    timeout=20s

Search Product
    [Arguments]    ${query}
    [Documentation]    Inputs query into search input field.
    Fill Text    ${PRODUCT_SEARCH_INPUT}    ${query}

Filter By Category
    [Arguments]    ${category_name}
    [Documentation]    Selects category from dropdown filter.
    Select Options By    ${CATEGORY_FILTER_SELECT}    text    ${category_name}

Sort Catalog By
    [Arguments]    ${sort_option}
    [Documentation]    Selects sorting strategy ('price-ascending' or 'price-descending').
    Select Options By    ${SORT_PRODUCTS_SELECT}    value    ${sort_option}

Add Product To Cart
    [Arguments]    ${product_id}
    [Documentation]    Clicks add to cart button for the designated product.
    Click    id=qa-add-${product_id}
    Wait For Elements State    id=qa-cart-row-${product_id}    visible    timeout=10s

Verify Product In Cart
    [Arguments]    ${product_id}
    [Documentation]    Asserts that the product row is visible in the cart.
    Get Element States    id=qa-cart-row-${product_id}    contains    visible

Change Cart Product Quantity
    [Arguments]    ${product_id}    ${quantity}
    [Documentation]    Updates quantity input for a product row.
    Fill Text    id=qa-quantity-${product_id}    ${quantity}

Remove Product From Cart
    [Arguments]    ${product_id}
    [Documentation]    Clicks the delete/remove button on a cart row.
    Click    id=qa-remove-${product_id}
    Wait For Elements State    id=qa-cart-row-${product_id}    detached    timeout=10s

Apply Promo Code
    [Arguments]    ${promo_code}
    [Documentation]    Fills promo code input and clicks apply button.
    Fill Text    ${PROMO_CODE_INPUT}    ${promo_code}
    Click        ${APPLY_PROMO_BTN}

Verify Cart Empty State
    [Documentation]    Asserts that empty cart state message is visible.
    Get Element States    ${CART_EMPTY_STATE}    contains    visible

Verify Feedback Message Contains
    [Arguments]    ${expected_text}
    [Documentation]    Validates feedback alert message content.
    Get Text    ${STORE_FEEDBACK_MSG}    contains    ${expected_text}
