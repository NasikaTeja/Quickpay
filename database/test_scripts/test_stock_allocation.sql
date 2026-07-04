DECLARE
P_MOBILE_NUMBER VARCHAR2(100):='9854336456';
P_AMOUNT NUMBER:=5600;
P_WALLET_ID NUMBER:=1;
P_SERVICE_ID NUMBER:=11;
P_CODE NUMBER;
P_MESSAGE VARCHAR2(100);

BEGIN

SP_CUSTOMER_STOCK_ALLOCATION(P_MOBILE_NUMBER,
                             P_AMOUNT,
                             P_WALLET_ID,
                             P_SERVICE_ID,
                             P_CODE,
                             P_MESSAGE);

DBMS_OUTPUT.PUT_LINE('Code    : ' || P_CODE);
DBMS_OUTPUT.PUT_LINE('Message : ' || P_MESSAGE);
END;