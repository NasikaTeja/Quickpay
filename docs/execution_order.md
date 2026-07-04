# Database Execution Order

## Purpose

This document describes the recommended execution sequence for all Oracle SQL and PL/SQL scripts in the **QuickPay** project. Following this order ensures that all database dependencies are resolved correctly.

---

# Execution Flow

```text
1. Tables
        ↓
2. Sequences
        ↓
3. Master Data (Optional)
        ↓
4. Functions
        ↓
5. Procedures
        ↓
6. Package Specification
        ↓
7. Package Body (If Available)
        ↓
8. Testing
```

---

# Step 1 - Create Tables

Execute all table scripts.

```text
Tables/
│
├── RE_ADDRESS_PROOF_TYPE_DETAILS.sql
├── RE_IDENTITY_PROF_TYPE_DETAILS.sql
├── RE_COUNTRY_INFO.sql
├── RE_SERVICE_PROVIDER_DETAILS.sql
├── RE_TBL_CUSTOMER_AUTHENTICATION.sql
├── RE_WALLET_TYPES.sql
├── RE_TBL_CUSTOMER_STATUS.sql
├── RE_TBL_SERVICE_TYPES.sql
├── RE_SERVICE_DETAILS.sql
├── RE_STATE_INFO.sql
├── RE_DISTRICT_INFO.sql
├── RE_MANDAL_INFO.sql
├── RE_VILLAGE_INFO.sql
├── RE_TBL_CUSTOMER_DETAILS.sql
├── RE_TBL_CUSTOMER_WALLET_DETAILS.sql
├── RE_TRANSACTION_DETAILS.sql
├── RE_TBL_CUSTOMER_GRADES.sql
├── RE_TBL_CUSTOMER_OTP_DETAILS.sql
├── RE_TBL_PASSWORD_CHANGE_HISTORY.sql
├── RE_TBL_LEDGER_DETAILS.sql
├── RE_TBL_TAX.sql
└── RE_TBL_COMMISTION.sql
```

---

# Step 2 - Create Sequences

Execute all sequence scripts.

```text
Sequences/
│
├── RE_ADDRESS_PROOF_TYPE_DETAILS_SEQ.sql
├── RE_IDENTITY_PROF_TYPE_DETAILS_SEQ.sql
├── RE_COUNTRY_INFO_SEQ.sql
├── RE_SERVICE_PROVIDER_DETAILS_SEQ.sql
├── RE_TBL_CUSTOMER_AUTHENTICATION_SEQ.sql
├── RE_WALLET_TYPES_SEQ.sql
├── RE_TBL_CUSTOMER_STATUS_SEQ.sql
├── RE_TBL_SERVICE_TYPES_SEQ.sql
├── RE_SERVICE_DETAILS_SEQ.sql
├── RE_STATE_INFO_SEQ.sql
├── RE_DISTRICT_INFO_SEQ.sql
├── RE_MANDAL_INFO_SEQ.sql
├── RE_VILLAGE_INFO_SEQ.sql
├── RE_TBL_CUSTOMER_DETAILS_SEQ.sql
├── RE_TBL_CUSTOMER_WALLET_DETAILS_SEQ.sql
├── RE_TRANSACTION_DETAILS_SEQ.sql
├── RE_TBL_CUSTOMER_GRADES_SEQ.sql
├── RE_TBL_CUSTOMER_OTP_DETAILS_SEQ.sql
├── RE_TBL_PASSWORD_CHANGE_HISTORY_SEQ.sql
├── RE_TBL_LEDGER_DETAILS_SEQ.sql
├── RE_TBL_TAX_SEQ.sql
└── RE_TBL_COMMISTION_SEQ.sql
```

---

# Step 3 - Insert Master Data (Optional)

Load the required master/reference data before testing procedures.

Example:

* Address Proof Types
* Identity Proof Types
* Countries
* States
* Districts
* Mandals
* Villages
* Wallet Types
* Customer Status
* Service Providers
* Service Types
* Services
* Tax
* Commission
* Customer Grades

---

# Step 4 - Create Functions

Execute all lookup functions.

```text
Functions/
│
├── FN_GET_CUSTOMER_PARENT_ID.sql
├── FN_GET_CUSTOMER_STATUS_ID.sql
├── FN_GET_RE_ADDRESS_PROOF_TYPE_DETAILS.sql
├── FN_GET_RE_COUNTRY_INFO.sql
├── FN_GET_RE_DISTRICT_INFO.sql
├── FN_GET_RE_IDENTITY_PROF_TYPE_DETAILS.sql
├── FN_GET_RE_MANDAL_INFO.sql
├── FN_GET_RE_STATE_INFO.sql
└── FN_GET_RE_VILLAGE_INFO.sql
```

---

# Step 5 - Create Procedures

Execute all procedure scripts.

```text
Procedures/
│
├── SP_RE_CUSTOMER_ONBOARDING.sql
├── SP_USER_LOGIN.sql
├── SP_FORGET_PASSWORD.sql
├── SP_CUSTOMER_STOCK_ALLOCATION.sql
├── SP_STOCK_MOVEMENT.sql
└── SP_TRANSACTION_DETAILS.sql
```

---

# Step 6 - Create Package Specification

```text
Packages/
│
└── QUICKPAY_PACKAGE.pks
```

---

# Step 7 - Create Package Body (Optional)

If a package body is implemented, execute it after the package specification.

```text
Packages/
│
└── QUICKPAY_PACKAGE.pkb
```

---

# Step 8 - Perform Functional Testing

Suggested testing sequence:

1. Insert master data.
2. Execute customer onboarding.
3. Verify customer authentication.
4. Allocate wallet balance.
5. Transfer stock between parent and child customers.
6. Initiate a transaction.
7. Process transaction success.
8. Process transaction failure.
9. Reset password using OTP.
10. Verify transaction history and ledger entries.

