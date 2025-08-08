
-- Ecommerce SQL Database Schema with Queries and Optimization
-- ===========================================================

-- 1. Users Table
CREATE TABLE Users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100),
    email VARCHAR(100) UNIQUE,
    password_hash VARCHAR(255),
    address TEXT,
    phone VARCHAR(20),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- 2. Categories Table
CREATE TABLE Categories (
    category_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) UNIQUE,
    description TEXT
);

-- 3. Products Table
CREATE TABLE Products (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(150),
    description TEXT,
    price DECIMAL(10,2),
    stock_quantity INT,
    category_id INT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES Categories(category_id)
);

-- 4. Orders Table
CREATE TABLE Orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    order_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    total_amount DECIMAL(10,2),
    status VARCHAR(50),
    FOREIGN KEY (user_id) REFERENCES Users(user_id)
);

-- 5. Order_Items Table
CREATE TABLE Order_Items (
    order_item_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT,
    product_id INT,
    quantity INT,
    unit_price DECIMAL(10,2),
    FOREIGN KEY (order_id) REFERENCES Orders(order_id),
    FOREIGN KEY (product_id) REFERENCES Products(product_id)
);

-- 6. Payments Table
CREATE TABLE Payments (
    payment_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT,
    payment_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    amount DECIMAL(10,2),
    payment_method VARCHAR(50),
    status VARCHAR(50),
    FOREIGN KEY (order_id) REFERENCES Orders(order_id)
);

-- 7. Reviews Table
CREATE TABLE Reviews (
    review_id INT PRIMARY KEY AUTO_INCREMENT,
    product_id INT,
    user_id INT,
    rating INT CHECK (rating BETWEEN 1 AND 5),
    comment TEXT,
    review_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES Products(product_id),
    FOREIGN KEY (user_id) REFERENCES Users(user_id)
);

-- 8. Shipping Table
CREATE TABLE Shipping (
    shipping_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT,
    shipping_method VARCHAR(100),
    tracking_number VARCHAR(100),
    shipped_date DATETIME,
    delivery_date DATETIME,
    status VARCHAR(50),
    FOREIGN KEY (order_id) REFERENCES Orders(order_id)
);

-- Sample Queries for Analysis
-- ===========================

-- a. SELECT, WHERE, ORDER BY, GROUP BY
SELECT user_id, name, email, created_at
FROM Users
WHERE created_at > '2025-01-01'
ORDER BY created_at DESC;

SELECT c.name AS category, COUNT(p.product_id) AS total_products
FROM Products p
JOIN Categories c ON p.category_id = c.category_id
GROUP BY c.name
ORDER BY total_products DESC;

-- b. JOINs (INNER, LEFT, RIGHT)
SELECT o.order_id, u.name AS customer, p.name AS product, oi.quantity, oi.unit_price
FROM Orders o
INNER JOIN Users u ON o.user_id = u.user_id
INNER JOIN Order_Items oi ON o.order_id = oi.order_id
INNER JOIN Products p ON oi.product_id = p.product_id;

SELECT p.name, r.rating, r.comment
FROM Products p
LEFT JOIN Reviews r ON p.product_id = r.product_id;

-- c. Subqueries
SELECT name, price
FROM Products
WHERE price > (
    SELECT AVG(price) FROM Products
);

SELECT user_id, name
FROM Users
WHERE user_id IN (
    SELECT user_id
    FROM Orders
    GROUP BY user_id
    HAVING COUNT(order_id) > 3
);

-- d. Aggregate Functions (SUM, AVG)
SELECT DATE_FORMAT(order_date, '%Y-%m') AS month, SUM(total_amount) AS revenue
FROM Orders
GROUP BY month
ORDER BY month;

SELECT product_id, AVG(rating) AS avg_rating
FROM Reviews
GROUP BY product_id
ORDER BY avg_rating DESC;

-- e. Create Views
CREATE VIEW Product_Sales_Summary AS
SELECT 
    p.product_id,
    p.name AS product_name,
    SUM(oi.quantity) AS total_units_sold,
    SUM(oi.quantity * oi.unit_price) AS total_sales
FROM Order_Items oi
JOIN Products p ON oi.product_id = p.product_id
GROUP BY p.product_id, p.name;

-- f. Optimize Queries with Indexes
CREATE INDEX idx_user_email ON Users(email);
CREATE INDEX idx_product_category ON Products(category_id);
CREATE INDEX idx_order_user ON Orders(user_id);
CREATE INDEX idx_order_date ON Orders(order_date);
CREATE INDEX idx_reviews_product ON Reviews(product_id);
