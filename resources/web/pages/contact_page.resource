*** Settings ***
Documentation    Page Object for Contact Section and Inquiries.
Resource         ../web_common.resource

*** Variables ***
${CONTACT_NAME_INPUT}       css=input[name="name"], id=name
${CONTACT_EMAIL_INPUT}      css=input[name="email"], id=email
${CONTACT_SUBJECT_INPUT}    css=input[name="subject"], id=subject
${CONTACT_MESSAGE_INPUT}    css=textarea[name="message"], id=message
${CONTACT_SUBMIT_BTN}       css=button[type="submit"]
${CONTACT_ALERT_SUCCESS}    css=[data-testid="contact-success"], .alert-success

*** Keywords ***
Fill Contact Form
    [Arguments]    ${name}    ${email}    ${subject}    ${message}
    [Documentation]    Fills all required contact form inputs.
    Fill Text    ${CONTACT_NAME_INPUT}       ${name}
    Fill Text    ${CONTACT_EMAIL_INPUT}      ${email}
    Fill Text    ${CONTACT_SUBJECT_INPUT}    ${subject}
    Fill Text    ${CONTACT_MESSAGE_INPUT}    ${message}

Submit Contact Form
    [Documentation]    Submits the contact form.
    Click    ${CONTACT_SUBMIT_BTN}
