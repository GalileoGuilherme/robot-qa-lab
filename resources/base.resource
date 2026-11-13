*** Settings ***
Documentation    Global Base Resource for Robot QA Lab.
...              Centralizes global configuration, environment variables,
...              and report enhancement listeners.

Variables        ../config/env.py
Library          ../libraries/ReportEnhancer.py
Library          OperatingSystem
Library          String
Library          Collections

*** Variables ***
${REPORTS_DIR}    ${CURDIR}/../results

*** Keywords ***
Global Suite Setup
    [Arguments]    ${suite_layer}=Full-Stack QA
    [Documentation]    Initializes suite metadata and ensures clean report directories.
    Inject Suite Metadata    ${suite_layer}
    Create Directory         ${REPORTS_DIR}
    Log    Starting Execution for Layer: ${suite_layer} on ${BASE_URL} (Env: ${ENV})    console=True

Global Suite Teardown
    [Documentation]    Finalizes suite run and logs completion status.
    Log    Suite execution completed successfully.    console=True
