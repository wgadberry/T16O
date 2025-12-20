CREATE 
    ALGORITHM = UNDEFINED 
    DEFINER = `root`@`%` 
    SQL SECURITY DEFINER
VIEW `vw_tx_token_last_activity` AS
    SELECT 
        `t`.`id` AS `token_id`,
        `a`.`address` AS `mint_address`,
        `t`.`token_symbol` AS `token_symbol`,
        `t`.`token_name` AS `token_name`,
        `t`.`decimals` AS `decimals`,
        `g`.`last_processed` AS `last_guide_activity_utc`
    FROM
        ((`tx_token` `t`
        JOIN `tx_address` `a` ON ((`a`.`id` = `t`.`mint_address_id`)))
        JOIN (SELECT 
            `g`.`token_id` AS `token_id`,
                MAX(`tx`.`created_at`) AS `last_processed`
        FROM
            (`tx_guide` `g`
        JOIN `tx` ON ((`tx`.`id` = `g`.`tx_id`)))
        WHERE
            (`g`.`token_id` IS NOT NULL)
        GROUP BY `g`.`token_id`) `g` ON ((`g`.`token_id` = `t`.`id`)));
