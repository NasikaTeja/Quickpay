CREATE OR REPLACE PROCEDURE SP_TRANSACTION_DETAILS
(
    P_MOBILE_NUMBER            IN VARCHAR2,
    P_SERVICE_ID              IN NUMBER,
    P_DESTINATION_MOBILE_NUMBER IN VARCHAR2,
    P_AMOUNT                  IN NUMBER,
    P_WALLET_TYPE_ID         IN NUMBER,
    P_TRANSACTION_TYPE       IN NUMBER,
    P_PASSWORD               IN VARCHAR2,
    P_TYPE                  IN NUMBER,
    P_RESPONSE_TYPE        IN NUMBER,
    P_TRANSACTION_ID      IN NUMBER,
    P_RESPONSE_TRANSACTION_ID IN NUMBER,
    P_CODE                 OUT NUMBER,
    P_MESSAGE              OUT VARCHAR2,
    P_OUT_TRANSACTION_ID OUT NUMBER
)
AS
    V_CUSTOMER_ID           NUMBER;
    V_STATUS                NUMBER;
    V_PASSWORD              VARCHAR2(100);
    V_BEFORE_BALANCE        NUMBER;
    V_AFTER_BALANCE         NUMBER;
    V_TR_STATUS             VARCHAR2(20);

    V_TAX_PERCENTAGE        NUMBER := 0;
    V_TAX_AMOUNT            NUMBER := 0;
    V_COMMISSION_PERCENTAGE NUMBER := 0;
    V_COMMISSION_AMOUNT     NUMBER := 0;

    V_TODAY_TOTAL           NUMBER;
    V_TRANSACTION_AMOUNT    NUMBER := 0;

BEGIN

    -- ======================================================
    -- CUSTOMER VALIDATION
    -- ======================================================
    BEGIN
        SELECT RE_RTCA_CUS_ID, RE_RTCA_CUS_STATUS, RE_RTCA_CUS_PASSWORD
        INTO V_CUSTOMER_ID, V_STATUS, V_PASSWORD
        FROM RE_TBL_CUSTOMER_AUTHENTICATION
        WHERE RE_RTCA_CUS_MOBILE_NUMBER = P_MOBILE_NUMBER;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            P_CODE := 101;
            P_MESSAGE := 'Mobile number not exists';
            RETURN;
    END;

    ------------------------------------------------------------------
    -- TYPE 1: INITIATE TRANSACTION
    ------------------------------------------------------------------
    IF P_TYPE = 1 THEN

        IF V_PASSWORD <> P_PASSWORD THEN
            P_CODE := 102;
            P_MESSAGE := 'Invalid password';
            RETURN;
        END IF;

        IF V_STATUS <> 1 THEN
            P_CODE := 103;
            P_MESSAGE := 'Customer is not active';
            RETURN;
        END IF;

        -- TAX
        BEGIN
            SELECT RE_TT_TAX_PERCENTAGE
            INTO V_TAX_PERCENTAGE
            FROM RE_TBL_TAX
            WHERE P_AMOUNT BETWEEN RE_TT_FROM_AMOUNT AND RE_TT_TO_AMOUNT
              AND RE_TT_SERVICE_ID = P_SERVICE_ID;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                V_TAX_PERCENTAGE := 0;
        END;

        V_TAX_AMOUNT := ROUND(P_AMOUNT * V_TAX_PERCENTAGE / 100, 2);

        -- COMMISSION
        BEGIN
            SELECT RE_TC_COMMISTION_PERSENTAGE
            INTO V_COMMISSION_PERCENTAGE
            FROM RE_TBL_COMMISTION
            WHERE P_AMOUNT BETWEEN RE_TC_FROM_AMOUNT AND RE_TC_TO_AMOUNT
              AND RE_TC_SERVICE_ID = P_SERVICE_ID;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                V_COMMISSION_PERCENTAGE := 0;
        END;

        V_COMMISSION_AMOUNT := ROUND(P_AMOUNT * V_COMMISSION_PERCENTAGE / 100, 2);

        -- WALLET LOCK
        SELECT RE_RTCWD_CUS_WALLET_AMOUNT
        INTO V_BEFORE_BALANCE
        FROM RE_TBL_CUSTOMER_WALLET_DETAILS
        WHERE RE_RTCWD_CUS_ID = V_CUSTOMER_ID
          AND RE_RTCWD_CUS_WALLET_ID = P_WALLET_TYPE_ID
        FOR UPDATE;

        -- DAILY LIMIT
        SELECT NVL(SUM(RE_TD_AMOUNT), 0)
        INTO V_TODAY_TOTAL
        FROM RE_TRANSACTION_DETAILS
        WHERE RE_TD_CUSTOMER_ID = V_CUSTOMER_ID
          AND TRUNC(RE_TD_CREATION_DATE) = TRUNC(SYSDATE);

        IF V_TODAY_TOTAL + P_AMOUNT > 100000 THEN
            P_CODE := 104;
            P_MESSAGE := 'Transaction limit exceeded for the day';
            RETURN;
        END IF;

        -- BALANCE CHECK
        IF V_BEFORE_BALANCE < (P_AMOUNT + V_TAX_AMOUNT) THEN
            P_CODE := 105;
            P_MESSAGE := 'Insufficient balance';
            RETURN;
        END IF;

        -- DEBIT WALLET
        UPDATE RE_TBL_CUSTOMER_WALLET_DETAILS
        SET RE_RTCWD_CUS_WALLET_AMOUNT =
            RE_RTCWD_CUS_WALLET_AMOUNT - (P_AMOUNT + V_TAX_AMOUNT)
        WHERE RE_RTCA_CUS_ID = V_CUSTOMER_ID
          AND RE_RTCWD_CUS_WALLET_ID = P_WALLET_TYPE_ID;

        -- INSERT TRANSACTION (PENDING)
        INSERT INTO RE_TRANSACTION_DETAILS
        VALUES (
            RE_TRANSACTION_DETAILS_SEQ.NEXTVAL,
            V_CUSTOMER_ID,
            P_WALLET_TYPE_ID,
            4,
            P_SERVICE_ID,
            P_AMOUNT,
            P_MOBILE_NUMBER,
            P_DESTINATION_MOBILE_NUMBER,
            NULL,
            P_AMOUNT + V_TAX_AMOUNT,
            0,
            V_TAX_AMOUNT,
            V_COMMISSION_AMOUNT,
            'PENDING',
            SYSDATE,
            NULL,
            0,
            SYSDATE,
            1,
            NULL,
            NULL,
            1,
            P_TRANSACTION_TYPE,
            NULL,
            NULL
        );

        P_OUT_TRANSACTION_ID := RE_TRANSACTION_DETAILS_SEQ.CURRVAL;

        SELECT RE_RTCWD_CUS_WALLET_AMOUNT
        INTO V_AFTER_BALANCE
        FROM RE_TBL_CUSTOMER_WALLET_DETAILS
        WHERE RE_RTCA_CUS_ID = V_CUSTOMER_ID;

        P_CODE := 0;
        P_MESSAGE := 'Transaction initiated successfully';

    ------------------------------------------------------------------
    -- TYPE 2: RESPONSE HANDLING
    ------------------------------------------------------------------
    ELSIF P_TYPE = 2 THEN

        SELECT RE_TD_CUSTOMER_ID,
               RE_TD_AMOUNT,
               RE_TD_TAX_AMOUNT,
               RE_TD_COMM_AMOUNT,
               RE_TD_TR_STATUS
        INTO V_CUSTOMER_ID,
             V_TRANSACTION_AMOUNT,
             V_TAX_AMOUNT,
             V_COMMISSION_AMOUNT,
             V_TR_STATUS
        FROM RE_TRANSACTION_DETAILS
        WHERE RE_TD_TRANSACTION_ID = P_TRANSACTION_ID
        FOR UPDATE;

        IF V_TR_STATUS <> 'PENDING' THEN
            P_CODE := 109;
            P_MESSAGE := 'Already processed';
            RETURN;
        END IF;

        IF P_TRANSACTION_ID <> P_RESPONSE_TRANSACTION_ID THEN
            P_CODE := 107;
            P_MESSAGE := 'Reference mismatch';
            RETURN;
        END IF;

        IF P_RESPONSE_TYPE = 0 THEN

            UPDATE RE_TRANSACTION_DETAILS
            SET RE_TD_TR_STATUS = 'SUCCESS',
                RE_TD_DESCRIPTION = 'Transaction Success',
                RE_TD_TR_COMPLETED_DATE = SYSDATE,
                RE_TD_ACTUAL_AMOUNT_CREDITED = V_COMMISSION_AMOUNT
            WHERE RE_TD_TRANSACTION_ID = P_TRANSACTION_ID;

            UPDATE RE_TBL_CUSTOMER_WALLET_DETAILS
            SET RE_RTCWD_CUS_WALLET_AMOUNT =
                RE_RTCWD_CUS_WALLET_AMOUNT + V_COMMISSION_AMOUNT
            WHERE RE_RTCA_CUS_ID = V_CUSTOMER_ID;

            P_MESSAGE := 'Transaction success, commission credited';

        ELSIF P_RESPONSE_TYPE = 1 THEN

            UPDATE RE_TRANSACTION_DETAILS
            SET RE_TD_TR_STATUS = 'FAILED',
                RE_TD_DESCRIPTION = 'Transaction Failed',
                RE_TD_TR_COMPLETED_DATE = SYSDATE
            WHERE RE_TD_TRANSACTION_ID = P_TRANSACTION_ID;

            UPDATE RE_TBL_CUSTOMER_WALLET_DETAILS
            SET RE_RTCWD_CUS_WALLET_AMOUNT =
                RE_RTCWD_CUS_WALLET_AMOUNT + (V_TRANSACTION_AMOUNT + V_TAX_AMOUNT)
            WHERE RE_RTCA_CUS_ID = V_CUSTOMER_ID;

            P_MESSAGE := 'Transaction failed, amount refunded';

        ELSE
            P_CODE := 108;
            P_MESSAGE := 'Invalid response type';
            RETURN;
        END IF;

        P_CODE := 0;
        P_OUT_TRANSACTION_ID := P_TRANSACTION_ID;

    END IF;

    COMMIT;

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        P_CODE := SQLCODE;
        P_MESSAGE := SQLERRM;
END;
/