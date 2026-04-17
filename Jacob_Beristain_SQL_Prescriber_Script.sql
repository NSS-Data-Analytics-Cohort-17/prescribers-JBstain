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
WHERE drug.opioid_drug_flag = 'Y'
GROUP BY prescriber.specialty_description
ORDER BY total_claims DESC
LIMIT 1;

--     b. Which specialty had the most total number of claims for opioids?


--     c. **Challenge Question:** Are there any specialties that appear in the prescriber table that have no associated prescriptions in the prescription table?


--     d. **Difficult Bonus:** *Do not attempt until you have solved all other problems!* For each specialty, report the percentage of total claims by that specialty which are for opioids. Which specialties have a high percentage of opioids?

-- 3. 
--     a. Which drug (generic_name) had the highest total drug cost?

--     b. Which drug (generic_name) has the hightest total cost per day? **Bonus: Round your cost per day column to 2 decimal places. Google ROUND to see how this works.**

-- 4. 
--     a. For each drug in the drug table, return the drug name and then a column named 'drug_type' which says 'opioid' for drugs which have opioid_drug_flag = 'Y', says 'antibiotic' for those drugs which have antibiotic_drug_flag = 'Y', and says 'neither' for all other drugs. **Hint:** You may want to use a CASE expression for this. See https://www.postgresqltutorial.com/postgresql-tutorial/postgresql-case/ 

--     b. Building off of the query you wrote for part a, determine whether more was spent (total_drug_cost) on opioids or on antibiotics. Hint: Format the total costs as MONEY for easier comparision.

-- 5. 
--     a. How many CBSAs are in Tennessee? **Warning:** The cbsa table contains information for all states, not just Tennessee.

--     b. Which cbsa has the largest combined population? Which has the smallest? Report the CBSA name and total population.

--     c. What is the largest (in terms of population) county which is not included in a CBSA? Report the county name and population.
