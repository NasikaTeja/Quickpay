CREATE OR REPLACE PROCEDURE SP_RE_CUSTOMER_ONBOARDING
(
    P_CUSTOMER_FIRST_NAME              IN VARCHAR2,
    P_CUSTOMER_MIDDLE_NAME             IN VARCHAR2,
    P_CUSTOMER_LAST_NAME               IN VARCHAR2,
    P_CUSTOMER_GENDER                  IN CHAR,
    P_CUSTOMER_DATE_OF_BIRTH           IN DATE,
    P_CUSTOMER_MOBILE_NUMBER           IN VARCHAR2,
    P_PARENT_CUSTOMER_ID               IN NUMBER,
    P_CUSTOMER_PERMANENT_ADDRESS       IN VARCHAR2,
    P_CUSTOMER_TEMPORARY_ADDRESS       IN VARCHAR2,
    P_CUSTOMER_IDENTITY_PROOF_NAME     IN VARCHAR2,
    P_CUSTOMER_IDENTITY_PROOF_NUMBER   IN VARCHAR2,
    P_CUSTOMER_ADDRESS_PROOF_NAME      IN VARCHAR2,
    P_CUSTOMER_ADDRESS_PROOF_NUMBER    IN VARCHAR2,
    P_COUNTRY_NAME                     IN VARCHAR2,
    P_STATE_NAME                       IN VARCHAR2,
    P_DISTRICT_NAME                    IN VARCHAR2,
    P_MANDAL_NAME                      IN VARCHAR2,
    P_VILLAGE_NAME                     IN VARCHAR2,
    P_PINCODE                          IN VARCHAR2,

    P_CODE                             OUT NUMBER,
    P_MESSAGE                          OUT VARCHAR2,
    P_CUSTOMER_ID                      OUT NUMBER
)
AS

    V_CUSTOMER_ID          NUMBER;
    V_PARENT_ID            NUMBER;
    V_COUNTRY_ID           NUMBER;
    V_STATE_ID             NUMBER;
    V_DISTRICT_ID          NUMBER;
    V_MANDAL_ID            NUMBER;
    V_VILLAGE_ID           NUMBER;
    V_ID_PROOF_ID          NUMBER;
    V_ADDR_PROOF_ID        NUMBER;

BEGIN

    -- =========================================================================
    -- VALIDATIONS
    -- =========================================================================

    IF P_CUSTOMER_MOBILE_NUMBER IS NULL THEN
        P_CODE := 104;
        P_MESSAGE := 'Mobile number is required';
        P_CUSTOMER_ID := 0;
        RETURN;
    ELSIF LENGTH(P_CUSTOMER_MOBILE_NUMBER) <> 10 THEN
        P_CODE := 105;
        P_MESSAGE := 'Mobile number must be 10 digits';
        P_CUSTOMER_ID := 0;
        RETURN;
    ELSIF P_CUSTOMER_FIRST_NAME IS NULL THEN
        P_CODE := 106;
        P_MESSAGE := 'First name is required';
        P_CUSTOMER_ID := 0;
        RETURN;
    ELSIF P_CUSTOMER_LAST_NAME IS NULL THEN
        P_CODE := 107;
        P_MESSAGE := 'Last name is required';
        P_CUSTOMER_ID := 0;
        RETURN;
    END IF;

    -- =========================================================================
    -- MASTER DATA LOOKUPS
    -- =========================================================================

    V_PARENT_ID     := FN_GET_CUSTOMER_PARENT_ID(P_PARENT_CUSTOMER_ID);
    V_COUNTRY_ID    := FN_GET_RE_COUNTRY_INFO(P_COUNTRY_NAME);
    V_STATE_ID      := FN_GET_RE_STATE_INFO(P_STATE_NAME);
    V_DISTRICT_ID   := FN_GET_RE_DISTRICT_INFO(P_DISTRICT_NAME);
    V_MANDAL_ID     := FN_GET_RE_MANDAL_INFO(P_MANDAL_NAME);
    V_VILLAGE_ID    := FN_GET_RE_VILLAGE_INFO(P_VILLAGE_NAME);
    V_ID_PROOF_ID   := FN_GET_RE_IDENTITY_PROF_TYPE_DETAILS(P_CUSTOMER_IDENTITY_PROOF_NAME);
    V_ADDR_PROOF_ID := FN_GET_RE_ADDRESS_PROOF_TYPE_DETAILS(P_CUSTOMER_ADDRESS_PROOF_NAME);

    -- =========================================================================
    -- MASTER VALIDATION CHECK
    -- =========================================================================

    IF V_PARENT_ID = -1 THEN
        P_CODE := 115;
        P_MESSAGE := 'Invalid parent customer';
        P_CUSTOMER_ID := 0;
        RETURN;
    ELSIF V_COUNTRY_ID = -1 THEN
        P_CODE := 110;
        P_MESSAGE := 'Invalid country';
        P_CUSTOMER_ID := 0;
        RETURN;
    ELSIF V_STATE_ID = -1 THEN
        P_CODE := 111;
        P_MESSAGE := 'Invalid state';
        P_CUSTOMER_ID := 0;
        RETURN;
    ELSIF V_DISTRICT_ID = -1 THEN
        P_CODE := 112;
        P_MESSAGE := 'Invalid district';
        P_CUSTOMER_ID := 0;
        RETURN;
    ELSIF V_MANDAL_ID = -1 THEN
        P_CODE := 113;
        P_MESSAGE := 'Invalid mandal';
        P_CUSTOMER_ID := 0;
        RETURN;
    ELSIF V_VILLAGE_ID = -1 THEN
        P_CODE := 114;
        P_MESSAGE := 'Invalid village';
        P_CUSTOMER_ID := 0;
        RETURN;
    ELSIF V_ID_PROOF_ID = -1 THEN
        P_CODE := 108;
        P_MESSAGE := 'Invalid identity proof';
        P_CUSTOMER_ID := 0;
        RETURN;
    ELSIF V_ADDR_PROOF_ID = -1 THEN
        P_CODE := 109;
        P_MESSAGE := 'Invalid address proof';
        P_CUSTOMER_ID := 0;
        RETURN;
    END IF;

    -- =========================================================================
    -- INSERT TRANSACTION
    -- =========================================================================

    SELECT CUSTOMER_ID_SEQ.NEXTVAL
    INTO V_CUSTOMER_ID
    FROM DUAL;

    INSERT INTO RE_TBL_CUSTOMER_AUTHENTICATION
    (
        RE_RTCA_CUS_ID,
        RE_RTCA_CUS_MOBILE_NUMBER,
        RE_RTCA_CUS_PASSWORD,
        RE_RTCA_CUS_NO_OF_ATTEMPTS,
        RE_RTCA_CUS_STATUS,
        RE_RTCA_CUS_CREATION_DATE,
        RE_RTCA_CUS_CREATED_BY,
        RE_RTCA_CUS_PARENT_CUS_ID
    )
    VALUES
    (
        V_CUSTOMER_ID,
        P_CUSTOMER_MOBILE_NUMBER,
        'QUICKPAY@123',
        0,
        1,
        SYSDATE,
        1,
        V_PARENT_ID
    );

    INSERT INTO RE_TBL_CUSTOMER_DETAILS
    (
        RE_RTCD_CUS_ID,
        RE_RTCD_CUS_FIRST_NAME,
        RE_RTCD_CUS_MIDDLE_NAME,
        RE_RTCD_CUS_LAST_NAME,
        RE_RTCD_CUS_GENDER,
        RE_RTCD_CUS_DOB,
        RE_RTCD_CUS_PERM_ADDRESS,
        RE_RTCD_CUS_TEMP_ADDRESS,
        RE_RTCD_CUS_IDENTITY_PROF_ID,
        RE_RTCD_CUS_IDENTITY_PROF_NO,
        RE_RTCD_CUS_ADDRESS_PROF_ID,
        RE_RTCD_CUS_ADDRESS_PROF_NO,
        RE_RTCD_CUS_COUNTRY_ID,
        RE_RTCD_CUS_STATE_ID,
        RE_RTCD_CUS_DISTRICT_ID,
        RE_RTCD_CUS_MANDAL_ID,
        RE_RTCD_CUS_VILLEGE_ID,
        RE_RTCD_CUS_PINCODE,
        RE_RTCD_CUS_CREATION_DATE,
        RE_RTCD_CUS_CREATED_BY
    )
    VALUES
    (
        V_CUSTOMER_ID,
        P_CUSTOMER_FIRST_NAME,
        P_CUSTOMER_MIDDLE_NAME,
        P_CUSTOMER_LAST_NAME,
        P_CUSTOMER_GENDER,
        P_CUSTOMER_DATE_OF_BIRTH,
        P_CUSTOMER_PERMANENT_ADDRESS,
        P_CUSTOMER_TEMPORARY_ADDRESS,
        V_ID_PROOF_ID,
        P_CUSTOMER_IDENTITY_PROOF_NUMBER,
        V_ADDR_PROOF_ID,
        P_CUSTOMER_ADDRESS_PROOF_NUMBER,
        V_COUNTRY_ID,
        V_STATE_ID,
        V_DISTRICT_ID,
        V_MANDAL_ID,
        V_VILLAGE_ID,
        P_PINCODE,
        SYSDATE,
        1
    );

    INSERT INTO RE_TBL_CUSTOMER_WALLET_DETAILS
    (
        RE_RTCWD_CUS_ID,
        RE_RTCWD_CUS_WALLET_ID,
        RE_RTCWD_CUS_WALLET_AMOUNT,
        RE_RTCWD_CUS_WALLET_CREATION_DATE,
        RE_RTCWD_CUS_WALLET_CREATED_BY
    )
    VALUES
    (
        V_CUSTOMER_ID,
        1,
        0,
        SYSDATE,
        1
    );

    -- =========================================================================
    -- SUCCESS RESPONSE
    -- =========================================================================

    P_CODE := 0;
    P_MESSAGE := 'Customer created successfully. ID: ' || V_CUSTOMER_ID;
    P_CUSTOMER_ID := V_CUSTOMER_ID;

    COMMIT;

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        P_CODE := SQLCODE;
        P_MESSAGE := SQLERRM;
        P_CUSTOMER_ID := 0;

END SP_RE_CUSTOMER_ONBOARDING;
/