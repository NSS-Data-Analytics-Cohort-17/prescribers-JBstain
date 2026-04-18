-- 1. a. Which prescriber had the highest total number of claims 
--       (totaled over all drugs)? Report the npi and the total number of claims.

SELECT COUNT(total_claim_count) as total_claims, prescriber.npi
FROM prescriber INNER JOIN prescription ON prescriber.npi = prescription.npi
GROUP BY prescriber.npi
ORDER BY total_claims DESC;


--    b. Repeat the above, but this time report the nppes_provider_first_name, nppes_provider_last_org_name,  specialty_description, and the total number of claims.

SELECT 
    prescriber.npi,
    COUNT(prescription.total_claim_count) AS total_claims,
    CONCAT(prescriber.nppes_provider_first_name, ', ', prescriber.nppes_provider_last_org_name) AS prescriber_name
FROM prescriber
INNER JOIN prescription 
    ON prescriber.npi = prescription.npi
GROUP BY 
    prescriber.npi,
    prescriber.nppes_provider_first_name,
    prescriber.nppes_provider_last_org_name
ORDER BY total_claims DESC;

-- 2. a. Which specialty had the most total number of claims (totaled over all drugs)?
SELECT  prescriber.specialty_description, SUM(prescription.total_claim_count) AS total_claims
FROM drug 
INNER JOIN prescription ON drug.drug_name = prescription.drug_name
INNER JOIN prescriber ON prescription.npi = prescriber.npi
GROUP BY prescriber.specialty_description
ORDER BY total_claims DESC;
		--FAMILY PRACTICE

--     b. Which specialty had the most total number of claims for opioids?
SELECT  prescriber.specialty_description, SUM(prescription.total_claim_count) AS total_claims
FROM drug 
INNER JOIN prescription ON drug.drug_name = prescription.drug_name
INNER JOIN prescriber ON prescription.npi = prescriber.npi
WHERE drug.opioid_drug_flag = 'Y'
GROUP BY prescriber.specialty_description
ORDER BY total_claims DESC
LIMIT 1;

--     c. **Challenge Question:** Are there any specialties that appear in the prescriber table that have no associated prescriptions in the prescription table?
SELECT DISTINCT prescriber.specialty_description
FROM prescription
	RIGHT JOIN prescriber ON prescription.npi = prescriber.npi
WHERE prescription.npi IS NULL

--     d.  For each specialty, report the percentage of total claims by that specialty which are for opioids.
--		   Which specialties have a high percentage of opioids?
SELECT prescriber.specialty_description, 
		SUM(CASE WHEN drug.opioid_drug_flag = 'Y' THEN total_claim_count ELSE 0 END) AS opioid_claim,
		ROUND(SUM(CASE WHEN drug.opioid_drug_flag = 'Y' THEN total_claim_count ELSE 0 END) *1 / SUM(prescription.total_claim_count)*100,2) AS raw_Percentage,
		CONCAT(ROUND(SUM(CASE WHEN drug.opioid_drug_flag = 'Y' THEN total_claim_count ELSE 0 END) *1 / SUM(prescription.total_claim_count)*100,2),'%') AS Specialist_Opioid_Percentage
FROM prescription
	INNER JOIN prescriber ON prescription.npi = prescriber.npi
	INNER JOIN drug on prescription.drug_name = drug.drug_name
GROUP BY prescriber.specialty_description
ORDER BY raw_Percentage DESC;

-- 3. 
--     a. Which drug (generic_name) had the highest total drug cost?
SELECT prescription.drug_name, drug.generic_name, prescription.total_drug_cost 
FROM drug 
	INNER JOIN prescription ON drug.drug_name = prescription.drug_name 
ORDER BY total_drug_cost DESC;




--     b. Which drug (generic_name) has the hightest total cost per day? **Bonus: Round your cost per day column to 2 decimal places. Google ROUND to see how this works.**
SELECT DISTINCT drug.generic_name,ROUND(SUM(total_drug_cost)/SUM(total_day_supply),2) AS cost_per_day
FROM drug 
	INNER JOIN prescription ON drug.drug_name = prescription.drug_name
GROUP BY drug.generic_name
ORDER BY cost_per_day DESC;


-- 4. 
--     a. For each drug in the drug table, return the drug name and then a column named 'drug_type' which says 'opioid' for drugs which have opioid_drug_flag = 'Y', 
--says 'antibiotic' for those drugs which have antibiotic_drug_flag = 'Y', and says 'neither' for all other drugs. **Hint:** 

SELECT  drug_name,
CASE
	WHEN opioid_drug_flag = 'Y' THEN 'opioid'
	WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
	ELSE 'neither'
	END AS drug_type
FROM drug;

--     b. Building off of the query you wrote for part a, determine whether more was spent (total_drug_cost) on opioids or on antibiotics. Hint: Format the total costs as MONEY for easier comparision.
SELECT
	CASE
		WHEN opioid_drug_flag = 'Y' THEN 'opioid'
		WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
	ELSE 'neither'
	END AS drug_type, TO_CHAR(SUM(prescription.total_drug_cost), 'FM$999,999,999,999.00') as total_cost
FROM drug
INNER JOIN prescription ON drug.drug_name = prescription.drug_name
	GROUP BY 
		CASE 
			WHEN opioid_drug_flag = 'Y' THEN 'opioid'
			WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
			ELSE 'neither'
		END;

		--More was spent on Opioids

-- 5. 
--     a. How many CBSAs are in Tennessee? **Warning:** The cbsa table contains information for all states, not just Tennessee.

SELECT COUNT(state)
FROM cbsa
INNER JOIN fips_county ON cbsa.fipscounty = fips_county.fipscounty
WHERE state = 'TN'

--     b. Which cbsa has the largest combined population? Which has the smallest? Report the CBSA name and total population.

SELECT cbsa, SUM(population) AS total_population
FROM cbsa
	INNER JOIN fips_county ON cbsa.fipscounty = fips_county.fipscounty
	INNER JOIN population ON fips_county.fipscounty = population.fipscounty
GROUP BY cbsa;
--     c. What is the largest (in terms of population) county which is not included in a CBSA? Report the county name and population.

SELECT county, SUM(population) AS county_sum_pop
FROM cbsa
	FULL JOIN fips_county ON cbsa.fipscounty = fips_county.fipscounty
	INNER JOIN population ON fips_county.fipscounty = population.fipscounty
WHERE cbsa IS NULL
GROUP BY county
ORDER BY county_sum_pop DESC;
-- 6. 
--     a. Find all rows in the prescription table where total_claims is at least 3000. Report the drug_name and the total_claim_count.
SELECT drug_name,total_claim_count
FROM prescription
WHERE total_claim_count >= 3000;
--     b. For each instance that you found in part a, add a column that indicates whether the drug is an opioid.

SELECT prescription.drug_name,prescription.total_claim_count,
	CASE
		WHEN opioid_drug_flag = 'Y' THEN 'Y'
		ELSE 'N'
	END AS opioid_flag
FROM prescription
	INNER JOIN drug ON prescription.drug_name = drug.drug_name
WHERE total_claim_count >= 3000;

--     c. Add another column to you answer from the previous part which gives the prescriber first and last name associated with each row.
SELECT prescription.drug_name,prescription.total_claim_count, CONCAT(nppes_provider_first_name, ' ',nppes_provider_last_org_name) AS Prescriber_Name,
	CASE
		WHEN opioid_drug_flag = 'Y' THEN 'Y'
		ELSE 'N'
	END AS opioid_flag
FROM prescription
	INNER JOIN drug ON prescription.drug_name = drug.drug_name
	INNER JOIN prescriber ON prescription.npi = prescriber.npi
WHERE total_claim_count >= 3000;

-- 7. The goal of this exercise is to generate a full list of all pain management specialists in Nashville and the number of claims they had for each opioid. **Hint:** The results from all 3 parts will have 637 rows.

--     a. First, create a list of all npi/drug_name combinations for pain management specialists (specialty_description = 'Pain Management) 
-- 																 in the city of Nashville (nppes_provider_city = 'NASHVILLE'), 
-- 																 where the drug is an opioid (opiod_drug_flag = 'Y'). **Warning:** 
-- Double-check your query before running it. You will only need to use the prescriber and drug tables since you don't need the claims numbers yet.

SELECT prescriber.npi, drug.drug_name
FROM Prescriber
	CROSS JOIN drug
WHERE specialty_description = 'Pain Management' AND nppes_provider_city = 'NASHVILLE' AND opioid_drug_flag = 'Y'

--  b & C (COALESCE NULLS TO 0 IN TOTAL COUNT). Next, report the number of claims per drug per prescriber. Be sure to include all combinations, whether or not the prescriber had any claims. 
--		  You should report the npi, the drug name, and the number of claims (total_claim_count).
    SELECT prescriber.npi, drug.drug_name, COALESCE(prescription.total_claim_count,0) AS total_claim_count
FROM Prescriber
	CROSS JOIN drug
	LEFT JOIN prescription ON prescriber.npi = prescription.npi
						  AND prescription.drug_name = drug.drug_name
WHERE specialty_description = 'Pain Management' 
	AND nppes_provider_city = 'NASHVILLE' 
	AND opioid_drug_flag = 'Y'
ORDER BY total_claim_count DESC;