-- Table row counts for t16o_db
-- Usage: mysql -h localhost -P 3396 -u root -p t16o_db < table-counts.sql

SELECT
    table_name AS 'Table',
    table_rows AS 'Rows',
    ROUND(data_length / 1024 / 1024, 2) AS 'Data_MB',
    ROUND(index_length / 1024 / 1024, 2) AS 'Index_MB'
FROM information_schema.tables
WHERE table_schema = 't16o_db'
  AND table_type = 'BASE TABLE'
ORDER BY table_rows DESC;
