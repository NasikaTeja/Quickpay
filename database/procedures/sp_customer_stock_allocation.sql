CREATE OR REPLACE PROCEDURE SP_CUSTOMER_STOCK_ALLOCATION
(
    P_MOBILE_NUMBER IN VARCHAR2,
    P_AMOUNT        IN NUMBER,
    P_WALLET_ID     IN NUMBER,
    P_SERVICE_ID    IN NUMBER,
    P_CODE          OUT NUMBER,
    P_MESSAGE       OUT VARCHAR2
)
AS

    V_AMOUNT           RE_TBL_CUSTOMER_WALLET_DETAILS.RE_RTCWD_CUS_WALLET_AMOUNT%TYPE;
    V_CUS_ID           RE_TBL_CUSTOMER_AUTHENTICATION.RE_RTCA_CUS_ID%TYPE;
    V_CUSTOMER_STATUS  RE_TBL_CUSTOMER_AUTHENTICATION.RE_RTCA_CUS_STATUS%TYPE;
    V_COUNT            NUMBER;

BEGIN

    -- =========================================================================
    -- FETCH CUSTOMER DETAILS
    -- =========================================================================

    BEGIN
        SELECT RE_RTCA_CUS_STATUS,
               RE_RTCA_CUS_ID
          INTO V_CUSTOMER_STATUS,
               V_CUS_ID
          FROM RE_TBL_CUSTOMER_AUTHENTICATION
         WHERE RE_RTCA_CUS_MOBILE_NUMBER = P_MOBILE_NUMBER;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            P_CODE := 301;
            P_MESSAGE := 'Customer does not exist';
            RETURN;
    END;

    -- =========================================================================
    -- VALIDATIONS
    -- =========================================================================

    IF V_CUSTOMER_STATUS <> 1 THEN
        P_CODE := 303;
        P_MESSAGE := 'Customer is not active';
        RETURN;
    END IF;

    IF P_AMOUNT <= 0 THEN
        P_CODE := 302;
        P_MESSAGE := 'Invalid amount';
        RETURN;
    END IF;

    -- =========================================================================
    -- UPDATE WALLET BALANCE
    -- =========================================================================

    SELECT RE_RTCWD_CUS_WALLET_AMOUNT
      INTO V_AMOUNT
      FROM RE_TBL_CUSTOMER_WALLET_DETAILS
     WHERE RE_RTCWD_CUS_ID = V_CUS_ID
       AND RE_RTCWD_CUS_WALLET_ID = P_WALLET_ID;

    UPDATE RE_TBL_CUSTOMER_WALLET_DETAILS
       SET RE_RTCWD_CUS_WALLET_AMOUNT =
           RE_RTCWD_CUS_WALLET_AMOUNT + P_AMOUNT
     WHERE RE_RTCWD_CUS_ID = V_CUS_ID
       AND RE_RTCWD_CUS_WALLET_ID = P_WALLET_ID;

    -- =========================================================================
    -- INSERT TRANSACTION DETAILS
    -- =========================================================================

    INSERT INTO RE_TRANSACTION_DETAILS
    (
        RE_TD_TRANSACTION_ID,
        RE_TD_CUSTOMER_ID,
        RE_TD_WALLET_ID,
        RE_TD_SP_ID,
        RE_TD_SD_ID,
        RE_TD_AMOUNT,
        RE_TD_CUSTOMER_MOBILE,
        RE_TD_DESTINATION_MOBILE,
        RE_TD_ACCOUNT_NUMBER,
        RE_TD_ACTUAL_AMOUNT_DEDUCTED,
        RE_TD_ACTUAL_AMOUNT_CREDITED,
        RE_TD_TAX_AMOUNT,
        RE_TD_COMM_AMOUNT,
        RE_TD_TR_STATUS,
        RE_TD_TRANSACTION_DATE,
        RE_TD_TR_COMPLETED_DATE,
        RE_TD_OTHER_CHARGES,
        RE_TD_CREATION_DATE,
        RE_TD_CREATED_BY,
        SERVICE_ID
    )
    VALUES
    (
        RE_TRANSACTION_DETAILS_SEQ.NEXTVAL,
        V_CUS_ID,
        P_WALLET_ID,
        4,
        11,
        P_AMOUNT,
        P_MOBILE_NUMBER,
        NULL,
        NULL,
        0,
        P_AMOUNT,
        0,
        0,
        'SUCCESS',
        SYSDATE,
        SYSDATE,
        0,
        SYSDATE,
        1,
        P_SERVICE_ID
    );

    -- =========================================================================
    -- LEDGER UPDATE
    -- =========================================================================

    SELECT COUNT(*)
      INTO V_COUNT
      FROM RE_TBL_LEDGER_DETAILS
     WHERE RE_LD_CUSTOMER_ID = V_CUS_ID
       AND RE_LD_SERVICE_ID = P_SERVICE_ID
       AND RE_LD_WALLET_ID = P_WALLET_ID
       AND TRUNC(RE_LD_CREATION_DATE) = TRUNC(SYSDATE);

    IF V_COUNT > 0 THEN

        UPDATE RE_TBL_LEDGER_DETAILS
           SET RE_LD_CLOSING_BALANCE =
               RE_LD_CLOSING_BALANCE + P_AMOUNT
         WHERE RE_LD_CUSTOMER_ID = V_CUS_ID
           AND RE_LD_SERVICE_ID = P_SERVICE_ID
           AND RE_LD_WALLET_ID = P_WALLET_ID
           AND TRUNC(RE_LD_CREATION_DATE) = TRUNC(SYSDATE);

    ELSE

        INSERT INTO RE_TBL_LEDGER_DETAILS
        (
            RE_LD_CUSTOMER_ID,
            RE_LD_SERVICE_ID,
            RE_LD_WALLET_ID,
            RE_LD_CREATION_DATE,
            RE_LD_OPENING_BALANCE,
            RE_LD_CLOSING_BALANCE
        )
        VALUES
        (
            V_CUS_ID,
            P_SERVICE_ID,
            P_WALLET_ID,
            SYSDATE,
            V_AMOUNT,
            V_AMOUNT + P_AMOUNT
        );

    END IF;

    -- =========================================================================
    -- SUCCESS RESPONSE
    -- =========================================================================

    P_CODE := 0;
    P_MESSAGE := 'Stock allocation successful';

    COMMIT;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        ROLLBACK;
        P_CODE := 304;
        P_MESSAGE := 'Wallet not found';

    WHEN OTHERS THEN
        ROLLBACK;
        P_CODE := SQLCODE;
        P_MESSAGE := SQLERRM;

END SP_CUSTOMER_STOCK_ALLOCATION;
/