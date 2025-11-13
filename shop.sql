SET SQL_SAFE_UPDATES = 0;
SET SQL_SAFE_UPDATES = 1;


#prepare backup 
-- Step 1: View original table
SELECT * FROM shopping_behavior_updated;
CREATE TABLE shop LIKE shopping_behavior_updated ;
SELECT * FROM shop;
INSERT INTO shop SELECT * FROM shopping_behavior_updated;
SELECT * FROM shop;


#review describe
ALTER TABLE shop
CHANGE `Review Rating` `Review Rating` float;

ALTER TABLE shop
Add COLUMN review_desc text;

UPDATE shop
  set review_desc= CASE
    WHEN ROUND(`Review Rating`, 2) BETWEEN 0 AND 2.49 THEN 'Poor'
    WHEN ROUND(`Review Rating`, 2) BETWEEN 2.5 AND 3.4  THEN 'Good'
    WHEN ROUND(`Review Rating`, 2) BETWEEN 3.5 AND 3.9  THEN 'Great'
    WHEN ROUND(`Review Rating`, 2) BETWEEN 4 AND 5  THEN 'Amazing'
  END;
  
#check if it is registering females becuz of 1000 line cutoff
select Age,Gender from shop where Gender='Female';

#looking at dataset structure can drop discount applied, promo code , sub status
ALTER TABLE shop
drop `Discount Applied`;
ALTER TABLE shop
drop `Subscription Status`;
ALTER TABLE shop
drop `agerange`;

#age range
ALTER TABLE shop
Add COLUMN agerange text;

UPDATE shop
  set agerange= CASE
    WHEN `Age` BETWEEN 18 AND 29 THEN 'Young'
    WHEN `Age` BETWEEN 30 AND 50  THEN 'Middle-Aged'
    WHEN `Age` BETWEEN 51 AND 64 THEN 'Older'
    WHEN `Age` >=65 THEN 'Senior'
  END;