DELIMITER //
CREATE procedure physician_info (
IN pid varchar(128),
OUT specialty VARCHAR(128),
OUT experience INT)
BEGIN 	
	SELECT primary_specialty, experience_years INTO specialty, experience 
	FROM physicians	
	WHERE physicians.ssn = pid;
END //

DELIMITER //
CREATE TRIGGER adv_drug 
AFTER INSERT ON prescriptions 
FOR EACH ROW 
BEGIN \
    INSERT IGNORE INTO alerts (patient_id, physician_id, alert_date, drug1, drug2) 
    SELECT Distinct NEW.patient_id, NEW.physician_id, NEW.date, drug_name, NEW.drug_name 
    FROM prescriptions 
    WHERE patient_id = NEW.patient_id 
      AND (drug_name IN ( 
          SELECT drug_name_1 
          FROM adverse_reactions 
          WHERE drug_name_2 = NEW.drug_name 
      ) 
      OR drug_name IN ( 
          SELECT drug_name_2 
          FROM adverse_reactions 
          WHERE drug_name_1 = NEW.drug_name 
      )) ; 
END;
DELIMITER ;