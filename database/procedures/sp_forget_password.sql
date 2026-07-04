CREATE OR REPLACE PROCEDURE SP_FORGET_PASSWORD
(
    P_MOBILE_NUMBER IN VARCHAR2,
    P_TYPE          IN NUMBER,
    P_INOTP         IN NUMBER,
    P_NEW_PASSWORD  IN VARCHAR2,
    P_OTP           OUT NUMBER,
    P_CODE          OUT NUMBER,
    P_MESSAGE       OUT VARCHAR2
)
AS

    V_CUSTOMER_ID   NUMBER;
    V_OLD_PASSWORD  VARCHAR2(100);
    V_OTP_NUMBER    NUMBER;

BEGIN

    -- =========================================================================
    -- FETCH CUSTOMER DETAILS
    -- =========================================================================

    BEGIN
        SELECT RE_RTCA_CUS_ID,
               RE_RTCA_CUS_PASSWORD
          INTO V_CUSTOMER_ID,
               V_OLD_PASSWORD
          FROM RE_TBL_CUSTOMER_AUTHENTICATION
         WHERE RE_RTCA_CUS_MOBILE_NUMBER = P_MOBILE_NUMBER;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            P_CODE := 202;
            P_MESSAGE := 'Mobile number not registered';
            RETURN;
    END;

    -- =========================================================================
    -- GENERATE OTP (TYPE = 1)
    -- =========================================================================

    IF P_TYPE = 1 THEN

        P_OTP := TRUNC(DBMS_RANDOM.VALUE(100000, 999999));

        INSERT INTO RE_TBL_CUSTOMER_OTP_DETAILS
        (
            RE_COD_CUSTOMER_ID,
            RE_COD_MOBILE_NUMBER,
            RE_COD_OTP_NUMBER,
            RE_COD_SENT_DATE,
            RE_COD_STATUS
        )
        VALUES
        (
            V_CUSTOMER_ID,
            P_MOBILE_NUMBER,
            P_OTP,
            SYSDATE,
            0
        );

        P_CODE := 200;
        P_MESSAGE := 'OTP sent successfully';

    -- =========================================================================
    -- VALIDATE OTP & RESET PASSWORD (TYPE = 2)
    -- =========================================================================

    ELSIF P_TYPE = 2 THEN

        SELECT RE_COD_OTP_NUMBER
          INTO V_OTP_NUMBER
          FROM RE_TBL_CUSTOMER_OTP_DETAILS
         WHERE RE_COD_CUSTOMER_ID = V_CUSTOMER_ID
           AND RE_COD_STATUS = 0
           AND RE_COD_SENT_DATE >= SYSDATE - INTERVAL '5' MINUTE
         ORDER BY RE_COD_SENT_DATE DESC
         FETCH FIRST 1 ROWS ONLY;

        -- OTP validation
        IF V_OTP_NUMBER <> P_INOTP THEN
            P_CODE := 201;
            P_MESSAGE := 'Invalid OTP';
            RETURN;
        END IF;

        -- Update password
        UPDATE RE_TBL_CUSTOMER_AUTHENTICATION
           SET RE_RTCA_CUS_PASSWORD = P_NEW_PASSWORD,
               RE_RTCA_CUS_LAST_UPDATED_DATE = SYSDATE,
               RE_RTCA_CUS_LAST_UPDATED_BY = V_CUSTOMER_ID
         WHERE RE_RTCA_CUS_ID = V_CUSTOMER_ID;

        -- Mark OTP as used
        UPDATE RE_TBL_CUSTOMER_OTP_DETAILS
           SET RE_COD_STATUS = 1
         WHERE RE_COD_MOBILE_NUMBER = P_MOBILE_NUMBER
           AND RE_COD_OTP_NUMBER = P_INOTP;

        -- Password history
        INSERT INTO RE_TBL_PASSWORD_CHANGE_HISTORY
        (
            RE_PCH_CUSTOMER_ID,
            RE_PCH_MOBILE_NUMBER,
            RE_PCH_OLD_PASSWORD,
            RE_PCH_NEW_PASSWORD,
            RE_PCH_CREATED_DATE
        )
        VALUES
        (
            V_CUSTOMER_ID,
            P_MOBILE_NUMBER,
            V_OLD_PASSWORD,
            P_NEW_PASSWORD,
            SYSDATE
        );

        P_CODE := 203;
        P_MESSAGE := 'Password changed successfully';

        COMMIT;

    END IF;

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        P_CODE := SQLCODE;
        P_MESSAGE := SQLERRM;

END SP_FORGET_PASSWORD;
/