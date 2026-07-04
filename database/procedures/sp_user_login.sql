-- =============================================================================
-- File Name   : sp_user_login.sql
-- Procedure   : SP_USER_LOGIN
-- Module      : Authentication
-- Description : Validates user login using mobile number and password.
--              Handles login attempts and account blocking logic.
-- =============================================================================

CREATE OR REPLACE PROCEDURE SP_USER_LOGIN
(
    P_MOBILE_NUMBER IN VARCHAR2,
    P_PASSWORD      IN VARCHAR2,
    P_CODE          OUT NUMBER,
    P_MESSAGE       OUT VARCHAR2
)
AS

    V_MOBILE_NUMBER   RE_TBL_CUSTOMER_AUTHENTICATION.RE_RTCA_CUS_MOBILE_NUMBER%TYPE;
    V_PASSWORD        RE_TBL_CUSTOMER_AUTHENTICATION.RE_RTCA_CUS_PASSWORD%TYPE;
    V_STATUS          RE_TBL_CUSTOMER_AUTHENTICATION.RE_RTCA_CUS_STATUS%TYPE;
    V_NO_OF_ATTEMPTS  RE_TBL_CUSTOMER_AUTHENTICATION.RE_RTCA_CUS_NO_OF_ATTEMPTS%TYPE;

BEGIN

    -- =========================================================================
    -- FETCH USER DETAILS
    -- =========================================================================

    BEGIN
        SELECT RE_RTCA_CUS_MOBILE_NUMBER,
               RE_RTCA_CUS_PASSWORD,
               RE_RTCA_CUS_STATUS,
               RE_RTCA_CUS_NO_OF_ATTEMPTS
          INTO V_MOBILE_NUMBER,
               V_PASSWORD,
               V_STATUS,
               V_NO_OF_ATTEMPTS
          FROM RE_TBL_CUSTOMER_AUTHENTICATION
         WHERE RE_RTCA_CUS_MOBILE_NUMBER = P_MOBILE_NUMBER;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            P_CODE := 101;
            P_MESSAGE := 'Invalid mobile number';
            RETURN;
    END;

    -- =========================================================================
    -- PASSWORD VALIDATION
    -- =========================================================================

    IF V_PASSWORD = P_PASSWORD THEN

        -- Active user + attempts check
        IF V_STATUS = 1 AND V_NO_OF_ATTEMPTS < 3 THEN

            P_CODE := 0;
            P_MESSAGE := 'LOGIN SUCCESS';

            UPDATE RE_TBL_CUSTOMER_AUTHENTICATION
               SET RE_RTCA_CUS_NO_OF_ATTEMPTS = 0
             WHERE RE_RTCA_CUS_MOBILE_NUMBER = P_MOBILE_NUMBER;

        ELSE

            P_CODE := 103;
            P_MESSAGE := 'ACCOUNT STATUS: ' || FN_GET_CUSTOMER_STATUS_ID(V_STATUS);

        END IF;

    ELSE
        -- Wrong password
        P_CODE := 102;
        P_MESSAGE := 'INVALID PASSWORD';

        UPDATE RE_TBL_CUSTOMER_AUTHENTICATION
           SET RE_RTCA_CUS_NO_OF_ATTEMPTS =
               NVL(RE_RTCA_CUS_NO_OF_ATTEMPTS, 0) + 1
         WHERE RE_RTCA_CUS_MOBILE_NUMBER = P_MOBILE_NUMBER;

        -- Block account after 3 attempts
        IF V_NO_OF_ATTEMPTS >= 3 THEN

            UPDATE RE_TBL_CUSTOMER_AUTHENTICATION
               SET RE_RTCA_CUS_STATUS = 4
             WHERE RE_RTCA_CUS_MOBILE_NUMBER = P_MOBILE_NUMBER;

            P_CODE := 104;
            P_MESSAGE := 'ACCOUNT BLOCKED AFTER 3 INVALID ATTEMPTS';
            RETURN;

        END IF;

    END IF;

    COMMIT;

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        P_CODE := SQLCODE;
        P_MESSAGE := SQLERRM;

END SP_USER_LOGIN;
/