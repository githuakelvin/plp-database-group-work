
CREATE DATABASE IF NOT EXISTS bookstore_db;
USE bookstore_db;

-- Create the tables
CREATE TABLE book_language (
    language_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL
);

CREATE TABLE publisher (
    publisher_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    address VARCHAR(255)
);

CREATE TABLE author (
    author_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL
);

CREATE TABLE country (
    country_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL
);

CREATE TABLE address (
    address_id INT PRIMARY KEY AUTO_INCREMENT,
    street VARCHAR(255) NOT NULL,
    city VARCHAR(100) NOT NULL,
    state VARCHAR(100) NOT NULL,
    zip_code VARCHAR(20) NOT NULL,
    country_id INT NOT NULL,
    FOREIGN KEY (country_id) REFERENCES country(country_id)
);

CREATE TABLE address_status (
    address_status_id INT PRIMARY KEY AUTO_INCREMENT,
    status_name VARCHAR(50) NOT NULL
);

CREATE TABLE customer (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(20)
);

CREATE TABLE customer_address (
    customer_address_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    address_id INT NOT NULL,
    address_status_id INT NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES customer(customer_id),
    FOREIGN KEY (address_id) REFERENCES address(address_id),
    FOREIGN KEY (address_status_id) REFERENCES address_status(address_status_id)
);

CREATE TABLE book (
    book_id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(100) NOT NULL,
    language_id INT NOT NULL,
    publisher_id INT NOT NULL,
    publication_date DATE,
    price DECIMAL(10, 2) NOT NULL,
    isbn VARCHAR(255) UNIQUE,
    FOREIGN KEY (language_id) REFERENCES book_language(language_id),
    FOREIGN KEY (publisher_id) REFERENCES publisher(publisher_id)
);

CREATE TABLE book_author (
    book_id INT NOT NULL,
    author_id INT NOT NULL,
    PRIMARY KEY (book_id, author_id),
    FOREIGN KEY (book_id) REFERENCES book(book_id),
    FOREIGN KEY (author_id) REFERENCES author(author_id)
);



CREATE TABLE order_status (
    order_status_id INT PRIMARY KEY AUTO_INCREMENT,
    status_name VARCHAR(50) NOT NULL
);

CREATE TABLE shipping_method (
    shipping_method_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    cost DECIMAL(10, 2) NOT NULL
);

CREATE TABLE cust_order (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    order_date DATE NOT NULL,
    shipping_address_id INT NOT NULL,
    shipping_method_id INT NOT NULL,
    order_status_id INT NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES customer(customer_id),
    FOREIGN KEY (shipping_address_id) REFERENCES address(address_id),
    FOREIGN KEY (shipping_method_id) REFERENCES shipping_method(shipping_method_id),
    FOREIGN KEY (order_status_id) REFERENCES order_status(order_status_id)
);

CREATE TABLE order_line (
    order_line_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT NOT NULL,
    book_id INT NOT NULL,
    quantity INT NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES cust_order(order_id),
    FOREIGN KEY (book_id) REFERENCES book(book_id)
);

CREATE TABLE order_history (
    order_history_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT NOT NULL,
    order_status_id INT NOT NULL,
    status_change_date DATETIME NOT NULL,
    FOREIGN KEY (order_id) REFERENCES cust_order(order_id),
    FOREIGN KEY (order_status_id) REFERENCES order_status(order_status_id)
);

-- Insert sample data
INSERT INTO book_language (name) VALUES ('English'), ('Spanish'), ('French');
INSERT INTO publisher (name, address) VALUES ('Penguin Books', 'New York, NY'), ('HarperCollins', 'New York, NY'), ('Simon & Schuster', 'New York, NY');
INSERT INTO author (first_name, last_name) VALUES ('John', 'Smith'), ('Jane', 'Doe'), ('David', 'Johnson');
INSERT INTO country (name) VALUES ('USA'), ('Canada'), ('UK');
INSERT INTO address (street, city, state, zip_code, country_id) VALUES ('123 Main St', 'Anytown', 'CA', '12345', 1), ('456 Oak Ave', 'Sometown', 'NY', '67890', 1), ('789 Pine Ln', 'Somewhere', 'ON', 'L5R 3T7', 2);
INSERT INTO address_status (status_name) VALUES ('Current'), ('Old');
INSERT INTO customer (first_name, last_name, email, phone) VALUES ('Alice', 'Smith', 'alice.smith@example.com', '555-1234'), ('Bob', 'Johnson', 'bob.johnson@example.com', '555-5678');
INSERT INTO customer_address (customer_id, address_id, address_status_id) VALUES (1, 1, 1), (1, 2, 2), (2, 3, 1);
INSERT INTO book (title, language_id, publisher_id, publication_date, price, isbn) VALUES ('The Great Novel', 1, 1, '2020-01-15', 25.99, '978-0143110408'), ('Another Best Seller', 2, 2, '2022-03-20', 19.99, '978-0061120084'), ('A French Classic', 3, 3, '2021-05-10', 22.50, '978-0743273565');
INSERT INTO book_author (book_id, author_id) VALUES (1, 1), (1, 2), (2, 2), (3, 3);
INSERT INTO order_status (status_name) VALUES ('Pending'), ('Shipped'), ('Delivered'), ('Cancelled');
INSERT INTO shipping_method (name, cost) VALUES ('Standard', 5.99), ('Express', 12.99);
INSERT INTO cust_order (customer_id, order_date, shipping_address_id, shipping_method_id, order_status_id) VALUES (1, '2024-01-01', 1, 1, 1), (2, '2024-02-01', 3, 2, 2);
INSERT INTO order_line (order_id, book_id, quantity, price) VALUES (1, 1, 2, 25.99), (1, 2, 1, 19.99), (2, 3, 3, 22.50);
INSERT INTO order_history (order_id, order_status_id, status_change_date) VALUES (1, 1, '2024-01-01 10:00:00'), (1, 2, '2024-01-03 14:00:00'), (2, 2, '2024-02-01 12:00:00');

-- Create user and grant privileges
CREATE USER 'bookstore_admin'@'%' IDENTIFIED BY 'password'; -- Replace 'password'
GRANT ALL PRIVILEGES ON bookstore_db.* TO 'bookstore_admin'@'%';
FLUSH PRIVILEGES;

-- Example queries
-- Get all books with their authors
SELECT b.title, a.first_name, a.last_name
FROM book b
JOIN book_author ba ON b.book_id = ba.book_id
JOIN author a ON ba.author_id = a.author_id;

-- Get all orders for a customer
SELECT o.order_id, o.order_date, os.status_name
FROM cust_order o
JOIN order_status os ON o.order_status_id = os.order_status_id
WHERE o.customer_id = 1;

-- Get the total revenue for each book
SELECT b.title, SUM(ol.quantity * ol.price) AS total_revenue
FROM book b
JOIN order_line ol ON b.book_id = ol.book_id
GROUP BY b.title;
