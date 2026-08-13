create database bank;
use bank;

-- 1. Create Branches Table
CREATE TABLE Branches (
    branch_id INT IDENTITY(1,1) PRIMARY KEY,
    branch_name NVARCHAR(100) NOT NULL,
    branch_code NVARCHAR(20) UNIQUE NOT NULL,
    city NVARCHAR(50) NOT NULL
);

-- 2. Create Customers Table
CREATE TABLE Customers (
    customer_id INT IDENTITY(1,1) PRIMARY KEY,
    first_name NVARCHAR(50) NOT NULL,
    last_name NVARCHAR(50) NOT NULL,
    email NVARCHAR(100) UNIQUE NOT NULL,
    phone NVARCHAR(15) NOT NULL,
    branch_id INT NOT NULL,
    CONSTRAINT FK_Customers_Branches FOREIGN KEY (branch_id) REFERENCES Branches(branch_id)
);

-- 3. Create Accounts Table
CREATE TABLE Accounts (
    account_id INT IDENTITY(1,1) PRIMARY KEY,
    customer_id INT NOT NULL,
    branch_id INT NOT NULL,
    account_type NVARCHAR(20) CHECK (account_type IN ('Savings', 'Current', 'Fixed Deposit')),
    balance DECIMAL(15,2) NOT NULL DEFAULT 0.00,
    created_at DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_Accounts_Customers FOREIGN KEY (customer_id) REFERENCES Customers(customer_id),
    CONSTRAINT FK_Accounts_Branches FOREIGN KEY (branch_id) REFERENCES Branches(branch_id)
);

-- 4. Create Transactions Table
CREATE TABLE Transactions (
    transaction_id INT IDENTITY(1,1) PRIMARY KEY,
    account_id INT NOT NULL,
    transaction_type NVARCHAR(20) CHECK (transaction_type IN ('Deposit', 'Withdrawal', 'Transfer')),
    amount DECIMAL(15,2) NOT NULL,
    transaction_date DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_Transactions_Accounts FOREIGN KEY (account_id) REFERENCES Accounts(account_id)
);

-- 5. Create Loans Table
CREATE TABLE Loans (
    loan_id INT IDENTITY(1,1) PRIMARY KEY,
    customer_id INT NOT NULL,
    loan_type NVARCHAR(30) NOT NULL,
    loan_amount DECIMAL(15,2) NOT NULL,
    status NVARCHAR(20) CHECK (status IN ('Active', 'Closed', 'Pending', 'Defaulted')),
    issue_date DATE NOT NULL,
    CONSTRAINT FK_Loans_Customers FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
);

-- Populate Branches
INSERT INTO Branches (branch_name, branch_code, city) VALUES
('Connaught Place Branch', 'CP001', 'Delhi'),
('Bandra West Branch', 'BW002', 'Mumbai'),
('MG Road Branch', 'MG003', 'Bengaluru');

-- Populate Customers
INSERT INTO Customers (first_name, last_name, email, phone, branch_id) VALUES
('Rajesh', 'Kumar', 'rajesh@example.com', '9876543210', 1),
('Sneha', 'Reddy', 'sneha@example.com', '9876543211', 2),
('Vikram', 'Aditya', 'vikram@example.com', '9876543212', 1),
('Ananya', 'Iyer', 'ananya@example.com', '9876543213', 3),
('Arjun', 'Mehta', 'arjun@example.com', '9876543214', 2);

-- Populate Accounts (Balances in ₹)
INSERT INTO Accounts (customer_id, branch_id, account_type, balance) VALUES
(1, 1, 'Savings', 150000.00),  -- > 1 Lakh
(2, 2, 'Current', 45000.00),
(3, 1, 'Savings', 320000.00),  -- > 1 Lakh (Highest Balance)
(4, 3, 'Fixed Deposit', 85000.00),
(5, 2, 'Savings', 120000.00);  -- > 1 Lakh

-- Populate Transactions
INSERT INTO Transactions (account_id, transaction_type, amount, transaction_date) VALUES
(1, 'Deposit', 50000.00, '2026-08-01 10:00:00'),
(1, 'Withdrawal', 5000.00, '2026-08-02 11:30:00'),
(1, 'Deposit', 20000.00, '2026-08-03 14:15:00'),
(2, 'Deposit', 45000.00, '2026-08-01 09:45:00'),
(3, 'Deposit', 100000.00, '2026-08-04 16:00:00'),
(3, 'Withdrawal', 12000.00, '2026-08-05 12:20:00'),
(3, 'Deposit', 50000.00, '2026-08-06 15:10:00'),
(3, 'Transfer', 15000.00, '2026-08-07 10:05:00'),
(5, 'Deposit', 120000.00, '2026-08-02 13:00:00');

-- Populate Loans
INSERT INTO Loans (customer_id, loan_type, loan_amount, status, issue_date) VALUES
(1, 'Home Loan', 4500000.00, 'Active', '2024-03-15'),
(2, 'Personal Loan', 300000.00, 'Active', '2025-01-10'),
(4, 'Car Loan', 850000.00, 'Active', '2025-06-20');


SELECT DISTINCT 
    c.customer_id, 
    c.first_name, 
    c.last_name, 
    a.account_type, 
    a.balance
FROM Customers c
INNER JOIN Accounts a ON c.customer_id = a.customer_id
WHERE a.balance > 100000.00
ORDER BY a.balance DESC;


SELECT TOP 1 
    c.customer_id, 
    c.first_name, 
    c.last_name, 
    a.account_id, 
    a.account_type, 
    a.balance AS highest_balance
FROM Customers c
INNER JOIN Accounts a ON c.customer_id = a.customer_id
ORDER BY a.balance DESC;


SELECT 
    b.branch_name, 
    ISNULL(SUM(t.amount), 0.00) AS total_deposited_amount
FROM Branches b
INNER JOIN Accounts a ON b.branch_id = a.branch_id
INNER JOIN Transactions t ON a.account_id = t.account_id
WHERE t.transaction_type = 'Deposit'
GROUP BY b.branch_name;


SELECT TOP 1 WITH TIES 
    c.customer_id, 
    c.first_name, 
    c.last_name, 
    COUNT(t.transaction_id) AS transaction_count
FROM Customers c
INNER JOIN Accounts a ON c.customer_id = a.customer_id
INNER JOIN Transactions t ON a.account_id = t.account_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY transaction_count DESC;



SELECT 
    b.branch_name, 
    CAST(AVG(a.balance) AS DECIMAL(15,2)) AS average_account_balance
FROM Branches b
INNER JOIN Accounts a ON b.branch_id = a.branch_id
GROUP BY b.branch_name;




SELECT TOP 1 
    l.loan_id, 
    c.first_name, 
    c.last_name, 
    l.loan_type, 
    l.loan_amount AS largest_loan, 
    l.issue_date
FROM Loans l
INNER JOIN Customers c ON l.customer_id = c.customer_id
ORDER BY l.loan_amount DESC;