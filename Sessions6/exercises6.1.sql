CREATE DATABASE exercises6_1;
USE exercises6_1;
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

-- Trigger cập nhật amount khi giá sản phẩm thay đổi
DELIMITER //
CREATE TRIGGER update_amount_on_price_change
AFTER UPDATE ON products
FOR EACH ROW
BEGIN
  IF NEW.price != OLD.price THEN
    UPDATE shopping_cart
    SET amount = NEW.price * quantity
    WHERE product_Id = NEW.id;
  END IF;
END //
DELIMITER ;

-- Trigger xóa sản phẩm liên quan trong shopping_cart khi sản phẩm bị xóa
DELIMITER //
CREATE TRIGGER delete_shopping_cart_on_product_delete
AFTER DELETE ON products
FOR EACH ROW
BEGIN
  DELETE FROM shopping_cart WHERE product_Id = OLD.id;
END //
DELIMITER ;

-- Trigger trừ số lượng sản phẩm khi thêm vào shopping_cart:
DELIMITER //
CREATE TRIGGER update_stock_on_cart_insert
AFTER INSERT ON shopping_cart
FOR EACH ROW
BEGIN
  UPDATE products
  SET stock = stock - NEW.quantity
  WHERE id = NEW.product_Id;
END //
DELIMITER ;





