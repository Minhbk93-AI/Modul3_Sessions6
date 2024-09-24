CREATE DATABASE exercises6_3;
USE exercises6_3;

CREATE TABLE users(
	id  INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100),
    muMoney DOUBLE,
    address VARCHAR(255),
    phone VARCHAR(11),
    dateOfBirthday DATE,
    status BIT(1)
);

CREATE TABLE transfer(
	sender_Id INT,
    receiver_Id INT,
    money DOUBLE,
    transfer_date DATE,
    FOREIGN KEY (sender_Id) REFERENCES users(id),
    FOREIGN KEY (receiver_Id) REFERENCES users(id)
);
DELIMITER //
CREATE PROCEDURE transfer_money(
    IN p_sender_Id INT,
    IN p_receiver_Id INT,
    IN p_money DOUBLE
)
BEGIN
    DECLARE sender_balance DOUBLE;

    -- Bắt đầu transaction
    START TRANSACTION;
    
    -- Kiểm tra số dư của người gửi
    SELECT muMoney INTO sender_balance
    FROM users
    WHERE id = p_sender_Id
    FOR UPDATE;
    
    -- Kiểm tra nếu số dư không đủ
    IF sender_balance < p_money THEN
        -- Nếu không đủ tiền, rollback transaction
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Insufficient funds';
    ELSE
        -- Nếu đủ tiền, cập nhật số dư của người gửi
        UPDATE users
        SET muMoney = muMoney - p_money
        WHERE id = p_sender_Id;
        
        -- Cập nhật số dư của người nhận
        UPDATE users
        SET muMoney = muMoney + p_money
        WHERE id = p_receiver_Id;
        
        -- Ghi lại lịch sử chuyển tiền
        INSERT INTO transfer (sender_Id, receiver_Id, money, transfer_date)
        VALUES (p_sender_Id, p_receiver_Id, p_money, CURDATE());
        
        -- Commit transaction nếu thành công
        COMMIT;
    END IF;
END //
DELIMITER ;

CALL transfer_money(1, 2, 500);
