DELIMITER //
SELECT physician_id, COUNT(*) c
FROM alerts 
GROUP BY physician_id
ORDER BY c DESC
//

DELIMITER //
SELECT p1.physician_id, p1.patient_id, p1.drug_name AS drug1, p2.drug_name AS drug2
FROM prescriptions p1 
JOIN prescriptions p2 ON (p1.patient_id = p2.patient_id)
	AND (p1.physician_id = p2.physician_id)
	AND (p1.date < p2.date)
JOIN adverse_reactions ar ON (p1.drug_name = ar.drug_name_1 AND p2.drug_name = ar.drug_name_2)
	OR (p1.drug_name = ar.drug_name_2 AND p2.drug_name = ar.drug_name_1)
//

DELIMITER //
SELECT p.physician_id, COUNT(*) AS drug_count
FROM prescriptions p
JOIN contracts con ON con.drug_name = p.drug_name
JOIN companies comp ON comp.id = con.company_id
WHERE comp.name = 'DRUGXO'
GROUP BY p.physician_id
//

DELIMITER //
SELECT con.drug_name, con.price / con.quantity AS price_per_unit, 
AVG(con.price / con.quantity) OVER (PARTITION BY con.drug_name) AS average_price_per_unit
FROM contracts con
JOIN companies comp ON comp.id = con.company_id
WHERE comp.name = 'PHARMASEE'
//

DELIMITER //
SELECT pre.drug_name, pf.pharmacy_id,
	(((pf.cost / pre.quantity) - (con.price / con.quantity)) / (con.price / con.quantity)) * 100 AS markup_percent
FROM pharmacy_fills pf
JOIN prescriptions pre ON pre.id = pf.prescription_id
JOIN contracts con ON con.drug_name = pre.drug_name
JOIN companies comp ON comp.id = con.company_id
//

DELIMITER //
SELECT pre.drug_name, 
	AVG(DATEDIFF(
    DATE_FORMAT(STR_TO_DATE(pf.date,'%d/%m/%Y'),'%Y-%m-%d'),
    DATE_FORMAT(STR_TO_DATE(pre.date,'%d/%m/%Y'),'%Y-%m-%d')
    )) AS average_days
FROM prescriptions pre
JOIN pharmacy_fills pf ON pre.id = pf.prescription_id
GROUP BY pre.drug_name
//



DELIMITER //
SELECT p.id AS pharmacy_id, pre.drug_name
FROM prescriptions pre
CROSS JOIN pharmacies p
LEFT JOIN pharmacy_fills pf ON pre.id = pf.prescription_id AND p.id = pf.pharmacy_id
WHERE pf.prescription_id IS NULL
GROUP BY p.id, pre.drug_name;
//
