SELECT * FROM transactions.credit_card;

SELECT id FROM credit_card
GROUP BY id;

ALTER TABLE credit_card ADD primary key(id);

ALTER TABLE transaction
ADD foreign key fk_credit_card(credit_card_id)
references credit_card(id);

SELECT * FROM credit_card
WHERE id = "CcU-2938";

UPDATE credit_card
SET iban = "R323456312213576817699999"
WHERE id = "CcU-2938";

SELECT * FROM transactions.credit_card;

ALTER TABLE credit_card DROP column pan;

insert into transaction
values ("108B1D1D-5B23-A76C-55EF-C568E49A99DD", "CcU-9999",
	"b-9999", "9999", "829.999", NOW(), "111.11", "0");
    
SET FOREIGN_KEY_CHECKS = 0;

select * FROM transaction
WHERE company_id = "b-9999";

select * from transaction
where id = "02C6201E-D90A-1859-B4EE-88D2986D3B02";

delete from transaction
where id = "02C6201E-D90A-1859-B4EE-88D2986D3B02";

