

-- Insert transformed data into the silver.crm_prd_info table
INSERT INTO silver.crm_prd_info (
    [prd_id],
    [cat_id],
    [prd_key],
    [prd_nm],
    [prd_cost],
    [prd_line],
    [prd_start_dt],
    [prd_end_dt]
)
SELECT 
    prd_id,
    -- Replace hyphens with underscores in the first 5 characters of prd_key to create cat_id
    REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,
    -- Extract the substring from the 7th character to the end of prd_key
    SUBSTRING(prd_key, 7, LEN(prd_key)) AS prd_key,
    prd_nm,
    -- Replace NULL values in prd_cost with 0
    ISNULL(prd_cost, 0) AS prd_cost,
    -- Transform prd_line values to more descriptive text
    CASE 
        WHEN UPPER(TRIM(prd_line)) = 'M' THEN 'Mountain'
        WHEN UPPER(TRIM(prd_line)) = 'R' THEN 'Road'
        WHEN UPPER(TRIM(prd_line)) = 'S' THEN 'Other Sales'
        WHEN UPPER(TRIM(prd_line)) = 'T' THEN 'Touring'
        ELSE 'NOT APPLICALBE'
    END AS prd_line,
    prd_start_dt,
    -- Calculate prd_end_dt as the day before the next prd_start_dt within the same prd_key partition
    CAST(
        DATEADD(day, -1, LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt))
        AS DATE
    ) AS prd_end_dt
FROM bronze.crm_prd_info;
