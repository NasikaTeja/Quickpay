# Project Overview

## QuickPay - Wallet & Recharge Management System

## Introduction

QuickPay is a database-driven Wallet and Recharge Management System developed using **Oracle SQL** and **PL/SQL**. The project simulates a real-world digital payment platform where customers can register, authenticate, maintain wallet balances, perform transactions, transfer stock within a distributor hierarchy, and manage recharge services.

The project follows a modular database architecture by separating database objects into Tables, Sequences, Functions, Procedures, and Packages, making it easier to maintain, deploy, and extend.

---

# Project Objectives

* Design a normalized Oracle database.
* Implement secure customer authentication.
* Manage wallet balances and stock allocation.
* Process recharge and payment transactions.
* Calculate tax and commission dynamically.
* Maintain transaction and ledger history.
* Demonstrate Oracle SQL and PL/SQL development practices.

---

# Business Modules

## 1. Customer Registration

* Register new customers.
* Validate identity and address proofs.
* Maintain parent-child customer hierarchy.
* Create authentication, customer profile, and wallet records.

---

## 2. Customer Authentication

* Login using mobile number and password.
* Track invalid login attempts.
* Automatically block customer after multiple failed attempts.
* Maintain customer status.

---

## 3. Forgot Password

* Generate One-Time Password (OTP).
* Verify OTP.
* Update password securely.
* Store password change history.

---

## 4. Wallet Management

* Create wallet during customer onboarding.
* Allocate wallet balance.
* Maintain wallet balance updates.
* Support multiple wallet types.

---

## 5. Stock Allocation

* Allocate wallet balance to customers.
* Validate customer status.
* Record allocation transaction.
* Update daily ledger.

---

## 6. Stock Movement

* Transfer balance from parent customer to child customer.
* Validate customer hierarchy.
* Update sender and receiver wallets.
* Record both debit and credit transactions.
* Maintain ledger entries.

---

## 7. Transaction Processing

The transaction module supports:

* Recharge transactions
* Wallet payments
* Tax calculation
* Commission calculation
* Pending transactions
* Success response
* Failed response
* Wallet refund for failed transactions
* Ledger updates
* Transaction history

---

# Database Components

| Component              |       Count |
| ---------------------- | ----------: |
| Tables                 |          22 |
| Sequences              |          22 |
| Functions              |           9 |
| Procedures             |           6 |
| Package Specifications |           1 |
| Primary Keys           | Implemented |
| Foreign Keys           | Implemented |
| Check Constraints      | Implemented |

---

# Project Workflow

```
Customer Registration
        │
        ▼
Customer Login
        │
        ▼
Wallet Creation
        │
        ▼
Stock Allocation
        │
        ▼
Stock Movement
        │
        ▼
Transaction Initiation
        │
        ▼
Tax & Commission Calculation
        │
        ▼
Pending Transaction
        │
        ▼
Service Provider Response
        │
        ├───────────────┐
        ▼               ▼
SUCCESS              FAILED
        │               │
Commission Added    Amount Refunded
        │               │
        └───────┬───────┘
                ▼
          Ledger Updated
```

---

# Oracle Features Used

* SQL DDL
* SQL DML
* Constraints
* Primary Keys
* Foreign Keys
* Check Constraints
* Sequences
* Functions
* Procedures
* Packages
* Exception Handling
* Transactions (COMMIT / ROLLBACK)
* DBMS_RANDOM
* FOR UPDATE Locking

---

# Repository Structure

```
QuickPay/
│
├── Tables/
├── Sequences/
├── Functions/
├── Procedures/
├── Packages/
├── Data/
├── Docs/
│   ├── project_overview.md
│   ├── project_flow.md
│   └── database_design.md
└── README.md
```
