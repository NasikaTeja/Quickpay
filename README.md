# QUICKPAY - The Recharge & Utility Payment Management System

## Project Overview

The Recharge & Utility Payment Management System (QuickPay) is an Oracle PL/SQL based backend application developed to manage customer onboarding, wallet management, stock allocation, stock movement, and recharge/service transactions for retailers and distributors.

The project follows a modular database architecture using Tables, Sequences, Functions, Procedures, and Packages to implement complete business logic at the database layer.

---

## Key Features

### Customer Management

* Customer Registration (Onboarding)
* Customer Authentication
* Customer Status Management
* Customer Profile Management
* Password Reset with OTP Verification

### Wallet Management

* Wallet Creation
* Wallet Balance Management
* Stock Allocation
* Stock Movement Between Parent and Child Customers

### Transaction Management

* Transaction Initiation
* Transaction Response Processing
* Transaction Status Tracking
* Commission Calculation
* Tax Calculation
* Daily Transaction Limit Validation

### Location Management

* Country Management
* State Management
* District Management
* Mandal Management
* Village Management

### Audit & Tracking

* Ledger Management
* OTP Tracking
* Password Change History
* Customer Grade Management

---

## Technology Stack

| Component            | Technology           |
| -------------------- | -------------------- |
| Database             | Oracle Database      |
| Language             | SQL                  |
| Programming Language | PL/SQL               |
| IDE                  | Oracle SQL Developer |              |

---

## Database Objects

### Tables

* RE_ADDRESS_PROOF_TYPE_DETAILS
* RE_IDENTITY_PROF_TYPE_DETAILS
* RE_COUNTRY_INFO
* RE_SERVICE_PROVIDER_DETAILS
* RE_TBL_CUSTOMER_AUTHENTICATION
* RE_WALLET_TYPES
* RE_TBL_CUSTOMER_STATUS
* RE_TBL_SERVICE_TYPES
* RE_SERVICE_DETAILS
* RE_STATE_INFO
* RE_DISTRICT_INFO
* RE_MANDAL_INFO
* RE_VILLAGE_INFO
* RE_TBL_CUSTOMER_DETAILS
* RE_TBL_CUSTOMER_WALLET_DETAILS
* RE_TRANSACTION_DETAILS
* RE_TBL_CUSTOMER_GRADES
* RE_TBL_CUSTOMER_OTP_DETAILS
* RE_TBL_PASSWORD_CHANGE_HISTORY
* RE_TBL_LEDGER_DETAILS
* RE_TBL_TAX
* RE_TBL_COMMISTION

Total Tables: 22

---

### Sequences

All primary key values are generated using Oracle Sequences.

Total Sequences: 22

---

### Functions

* FN_GET_CUSTOMER_PARENT_ID
* FN_GET_CUSTOMER_STATUS_ID
* FN_GET_RE_ADDRESS_PROOF_TYPE_DETAILS
* FN_GET_RE_COUNTRY_INFO
* FN_GET_RE_DISTRICT_INFO
* FN_GET_RE_IDENTITY_PROF_TYPE_DETAILS
* FN_GET_RE_MANDAL_INFO
* FN_GET_RE_STATE_INFO
* FN_GET_RE_VILLAGE_INFO

Total Functions: 9

---

### Procedures

* SP_RE_CUSTOMER_ONBOARDING
* SP_USER_LOGIN
* SP_FORGET_PASSWORD
* SP_CUSTOMER_STOCK_ALLOCATION
* SP_STOCK_MOVEMENT
* SP_TRANSACTION_DETAILS

Total Procedures: 6

---

### Package

* QUICKPAY_PACKAGE

The package exposes all business functions and procedures through a single interface.

---

## Project Structure

```text
QUICKPAY
│
├── tables
│
├── sequences
│
├── functions
│
├── procedures
│
├── packages
│
├── docs
│
└── README.md
```

---

## Business Flow

### Customer Onboarding

Customer Registration
→ Mobile Validation
→ Identity Validation
→ Address Validation
→ Customer Creation
→ Wallet Creation
→ Customer Activated

### Login Flow

Customer Login
→ Mobile Verification
→ Password Verification
→ Status Verification
→ Login Success

### Forgot Password Flow

Forgot Password
→ OTP Generation
→ OTP Validation
→ Password Update
→ Password History Tracking

### Stock Allocation Flow

Admin Allocation
→ Wallet Credit
→ Transaction Entry
→ Ledger Update

### Stock Movement Flow

Parent Wallet Debit
→ Child Wallet Credit
→ Transaction Recording
→ Ledger Update

### Transaction Flow

Transaction Initiation
→ Wallet Validation
→ Tax Calculation
→ Commission Calculation
→ Wallet Debit
→ Transaction Creation
→ Response Processing
→ Success / Failure Handling
→ Ledger Update

---

## Security Features

* OTP Based Password Reset
* Customer Status Validation
* Login Attempt Tracking
* Account Blocking After Multiple Invalid Attempts
* Transaction Limit Validation
* Foreign Key Constraints
* Check Constraints
* Data Integrity Validation
