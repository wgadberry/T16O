SELECT * FROM t16o_db.vw_tx_funding_chain;

drop view if exists vw_tx_funding_chain;
CREATE 
VIEW vw_tx_funding_chain2 AS
    SELECT 
        w.id AS wallet_id,
        w.address AS wallet_address,
        max(f1.id) AS funder_1_id,
        max(f1.address) AS funder_1_address,
        max(f1.label) AS funder_1_label,
        max(f2.id) AS funder_2_id,
        max(f2.address) AS funder_2_address,
        max(f2.label) AS funder_2_label,
        max((w.funding_amount / 1E9)) AS funding_sol
    FROM
		tx_address w
        LEFT JOIN tx_address f1 ON w.funded_by_address_id = f1.id
        LEFT JOIN tx_address f2 ON f1.funded_by_address_id = f2.id
    WHERE
     w.address_type IN ('wallet' , 'unknown')
	AND w.funded_by_address_id IS NOT NULL
    group by w.id, w.address
    ;
