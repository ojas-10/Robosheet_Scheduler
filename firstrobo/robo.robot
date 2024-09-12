*** Settings ***
Library           Process
Library           DateTime
Library           OperatingSystem

*** Variables ***
${PYTHON_SCRIPT}    ${CURDIR}/tasks.py
${SCHEDULED_TIME}    13:04
${LOOP_INTERVAL}    60  # Check every 60 seconds



*** Test Cases ***
Schedule and Run Google Sheets Automation
    Log To Console    Starting scheduler. Will run script at ${SCHEDULED_TIME}
    ${manual_run}=    Get Time    format=%H:%M    #The time at which this script starts get executing.
    Set Global Variable    ${MANUAL_RUN_TIME}    ${manual_run}  #Making this variable global for further use
    Log To Console    Manual run time set to: ${MANUAL_RUN_TIME}
    
    FOR    ${i}    IN RANGE    999999 #loop will go till infinite
        ${current_time}=    Get Current Date    result_format=datetime      #it will be something like 10:59:36
        ${formatted_time}=    Convert Date    ${current_time}    result_format=%H:%M   #we will format it to 10:59
        Log To Console    Current time: ${formatted_time}
        Run Keyword If    '${formatted_time}' == '${SCHEDULED_TIME}' or '${formatted_time}' == '${MANUAL_RUN_TIME}'    Run Python Script    ${formatted_time}
        ...    ELSE    Log To Console    Not time to run script yet (${formatted_time})
        Sleep      60s       # Reduced interval for testing
    END

*** Keywords ***


Run Python Script
    [Arguments]    ${execution_time}
    Log To Console    Attempting to run Python script at ${execution_time}
    ${result}=    Run Process    python    ${PYTHON_SCRIPT}    shell=True    stdout=${CURDIR}/python_output.log    stderr=${CURDIR}/python_error.log
    ${stdout}=    Get File    ${CURDIR}/python_output.log   #Reads the content of the output and error log files.
    ${stderr}=    Get File    ${CURDIR}/python_error.log
    Log To Console    Python script output:
    Log To Console    ${stdout}
    Log To Console    Python script error output:
    Log To Console    ${stderr}
    ${status}=    Run Keyword And Return Status    Should Be Equal As Integers    ${result.rc}    0
    Run Keyword If    not ${status}    Log To Console    ERROR: Python script failed with return code ${result.rc}
    ...    ELSE IF    '${stderr}' != ''    Log To Console    WARNING: Python script encountered errors: ${stderr}
    ...    ELSE    Log To Console    Script executed successfully at ${execution_time}
    [Return]    ${status}

