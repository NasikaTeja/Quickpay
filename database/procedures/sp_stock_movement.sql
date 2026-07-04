CREATE OR REPLACE PROCEDURE SP_STOCK_MOVEMENT
(
    P_PARENT_MOBILE_NUMBER IN VARCHAR2,
    P_CHILD_MOBILE_NUMBER  IN VARCHAR2,
    P_AMOUNT               IN NUMBER,
    P_SERVICE_ID           IN NUMBER,
    P_CODE                 OUT NUMBER,
    P_MESSAGE              OUT VARCHAR2
)
AS
    V_MASTER_STATUS          NUMBER;
    V_MASTER_OPENING_BALANCE NUMBER;
    V_CHILD_OPENING_BALANCE  NUMBER;
    V_CHILD_PARENT_ID        NUMBER;
    V_MASTER_CUSTOMER_ID     NUMBER;
    V_CHILD_CUSTOMER_ID      NUMBER;
    V_CHILD_STATUS           NUMBER;
    V_MASTER_CLOSING_BALANCE NUMBER;
    V_CHILD_CLOSING_BALANCE  NUMBER;

BEGIN

    -- Validation: Same user transfer
    IF P_PARENT_MOBILE_NUMBER = P_CHILD_MOBILE_NUMBER THEN
        P_CODE := 107;
        P_MESSAGE := 'Parent and Child mobile numbers should not be same';
        RETURN;
    END IF;

    -- Validation: Amount
    IF P_AMOUNT <= 0 THEN
        P_CODE := 108;
        P_MESSAGE := 'Amount should be greater than 0';
        RETURN;
    END IF;

    -- Master validation
    BEGIN
        SELECT RE_RTCA_CUS_STATUS, RE_RTCA_CUS_ID
        INTO V_MASTER_STATUS, V_MASTER_CUSTOMER_ID
        FROM RE_TBL_CUSTOMER_AUTHENTICATION
        WHERE RE_RTCA_CUS_MOBILE_NUMBER = P_PARENT_MOBILE_NUMBER;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            P_CODE := 101;
            P_MESSAGE := 'Master customer not exists';
            RETURN;
    END;

    IF V_MASTER_STATUS <> 1 THEN
        P_CODE := 102;
        P_MESSAGE := 'Master is not active';
        RETURN;
    END IF;

    -- Master wallet check
    SELECT RE_RTCWD_CUS_WALLET_AMOUNT
    INTO V_MASTER_OPENING_BALANCE
    FROM RE_TBL_CUSTOMER_WALLET_DETAILS
    WHERE RE_RTCWD_CUS_ID = V_MASTER_CUSTOMER_ID
    FOR UPDATE;

    IF V_MASTER_OPENING_BALANCE < P_AMOUNT THEN
        P_CODE := 103;
        P_MESSAGE := 'Insufficient balance';
        RETURN;
    END IF;

    -- Child validation
    BEGIN
        SELECT RE_RTCA_CUS_STATUS, RE_RTCA_CUS_ID, RE_RTCA_CUS_PARENT_CUS_ID
        INTO V_CHILD_STATUS, V_CHILD_CUSTOMER_ID, V_CHILD_PARENT_ID
        FROM RE_TBL_CUSTOMER_AUTHENTICATION
        WHERE RE_RTCA_CUS_MOBILE_NUMBER = P_CHILD_MOBILE_NUMBER;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            P_CODE := 104;
            P_MESSAGE := 'Child not exists';
            RETURN;
    END;

    IF V_CHILD_STATUS <> 1 THEN
        P_CODE := 105;
        P_MESSAGE := 'Child is not active';
        RETURN;
    END IF;

    IF V_CHILD_PARENT_ID <> V_MASTER_CUSTOMER_ID THEN
        P_CODE := 106;
        P_MESSAGE := 'Child is not under this master';
        RETURN;
    END IF;

    -- Child wallet lock
    SELECT RE_RTCWD_CUS_WALLET_AMOUNT
    INTO V_CHILD_OPENING_BALANCE
    FROM RE_TBL_CUSTOMER_WALLET_DETAILS
    WHERE RE_RTCWD_CUS_ID = V_CHILD_CUSTOMER_ID
    FOR UPDATE;

    -- Wallet update
    UPDATE RE_TBL_CUSTOMER_WALLET_DETAILS
    SET RE_RTCWD_CUS_WALLET_AMOUNT = RE_RTCWD_CUS_WALLET_AMOUNT - P_AMOUNT
    WHERE RE_RTCWD_CUS_ID = V_MASTER_CUSTOMER_ID;

    UPDATE RE_TBL_CUSTOMER_WALLET_DETAILS
    SET RE_RTCWD_CUS_WALLET_AMOUNT = RE_RTCWD_CUS_WALLET_AMOUNT + P_AMOUNT
    WHERE RE_RTCWD_CUS_ID = V_CHILD_CUSTOMER_ID;

    -- Transaction (Master)
    INSERT INTO RE_TRANSACTION_DETAILS
    VALUES (
        RE_TRANSACTION_DETAILS_SEQ.NEXTVAL,
        V_MASTER_CUSTOMER_ID,
        1,
        4,
        P_SERVICE_ID,
        P_AMOUNT,
        P_PARENT_MOBILE_NUMBER,
        NULL,
        NULL,
        0,
        0,
        0,
        0,
        'SUCCESS',
        SYSDATE,
        SYSDATE,
        0,
        SYSDATE,
        1,
        NULL,
        NULL,
        NULL,
        P_SERVICE_ID,
        NULL,
        NULL
    );

    -- Transaction (Child)
    INSERT INTO RE_TRANSACTION_DETAILS
    VALUES (
        RE_TRANSACTION_DETAILS_SEQ.NEXTVAL,
        V_CHILD_CUSTOMER_ID,
        1,
        4,
        P_SERVICE_ID,
        P_AMOUNT,
        P_CHILD_MOBILE_NUMBER,
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
        NULL,
        NULL,
        1,
        P_SERVICE_ID,
        NULL,
        NULL
    );

    -- Closing balances
    SELECT RE_RTCWD_CUS_WALLET_AMOUNT
    INTO V_MASTER_CLOSING_BALANCE
    FROM RE_TBL_CUSTOMER_WALLET_DETAILS
    WHERE RE_RTCWD_CUS_ID = V_MASTER_CUSTOMER_ID;

    SELECT RE_RTCWD_CUS_WALLET_AMOUNT
    INTO V_CHILD_CLOSING_BALANCE
    FROM RE_TBL_CUSTOMER_WALLET_DETAILS
    WHERE RE_RTCWD_CUS_ID = V_CHILD_CUSTOMER_ID;

    -- Ledger master
    INSERT INTO RE_TBL_LEDGER_DETAILS
    VALUES (
        V_MASTER_CUSTOMER_ID,
        P_SERVICE_ID,
        1,
        SYSDATE,
        V_MASTER_OPENING_BALANCE,
        V_MASTER_CLOSING_BALANCE
    );

    -- Ledger child
    INSERT INTO RE_TBL_LEDGER_DETAILS
    VALUES (
        V_CHILD_CUSTOMER_ID,
        P_SERVICE_ID,
        1,
        SYSDATE,
        V_CHILD_OPENING_BALANCE,
        V_CHILD_CLOSING_BALANCE
    );

    P_CODE := 200;
    P_MESSAGE := 'Stock Movement Successful';

    COMMIT;

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        P_CODE := SQLCODE;
        P_MESSAGE := SQLERRM;
END;
/