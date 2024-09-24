CREATE DATABASE exercises6_2;
USE exercises6_2;
CREATE TABLE users(
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  address VARCHAR(255) NOT NULL,
  phone VARCHAR(11),
  dateOfBirth DATE,
  status BIT(1)
);

CREATE TABLE shopping_cart(
 id INT AUTO_INCREMENT PRIMARY KEY,
 user_Id INT,
 product_Id INT,
 quantity INT,
 amount DOUBLE,
 FOREIGN KEY(user_Id) REFERENCES users(id),
 FOREIGN KEY(product_Id) REFERENCES products(id)
);

CREATE TABLE products(
	id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100),
    price DOUBLE,
    stock INT,
    status BIT(1)
);

DELIMITER //
CREATE PROCEDURE add_to_cart(
    IN p_user_Id INT,
    IN p_product_Id INT,
    IN p_quantity INT
)
BEGIN
    DECLARE available_stock INT;

    -- Bắt đầu transaction
    START TRANSACTION;
    
    -- Kiểm tra số lượng sản phẩm còn trong kho
    SELECT stock INTO available_stock
    FROM products
    WHERE id = p_product_Id
    FOR UPDATE;
    
    -- Kiểm tra xem có đủ hàng không
    IF available_stock < p_quantity THEN
        -- Nếu không đủ hàng, rollback transaction
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Not enough stock available';
    ELSE
        -- Nếu đủ hàng, thêm vào giỏ hàng và cập nhật số lượng trong kho
        INSERT INTO shopping_cart (user_Id, product_Id, quantity, amount)
        VALUES (p_user_Id, p_product_Id, p_quantity, 
                (SELECT price FROM products WHERE id = p_product_Id) * p_quantity);
        
        -- Cập nhật số lượng sản phẩm trong kho
        UPDATE products
        SET stock = stock - p_quantity
        WHERE id = p_product_Id;
        
        -- Commit transaction nếu thành công
        COMMIT;
    END IF;
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE remove_from_cart(
    IN p_cart_Id INT
)
BEGIN
    DECLARE p_product_Id INT;
    DECLARE p_quantity INT;

    -- Bắt đầu transaction
    START TRANSACTION;
    
    -- Lấy thông tin product_Id và quantity từ giỏ hàng
    SELECT product_Id, quantity INTO p_product_Id, p_quantity
    FROM shopping_cart
    WHERE id = p_cart_Id
    FOR UPDATE;

    -- Xóa sản phẩm khỏi giỏ hàng
    DELETE FROM shopping_cart
    WHERE id = p_cart_Id;

    -- Cập nhật số lượng sản phẩm trong kho
    UPDATE products
    SET stock = stock + p_quantity
    WHERE id = p_product_Id;

    -- Commit transaction
    COMMIT;
END //
DELIMITER ;
