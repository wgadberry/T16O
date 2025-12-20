CREATE 
    ALGORITHM = UNDEFINED 
    DEFINER = `root`@`%` 
    SQL SECURITY DEFINER
VIEW `vw_tx_token_stats` AS
    SELECT 
        `t`.`id` AS `token_id`,
        `a`.`address` AS `mint_address`,
        `t`.`token_symbol` AS `token_symbol`,
        `t`.`token_name` AS `token_name`,
        `t`.`decimals` AS `decimals`,
        (SELECT 
                COUNT(DISTINCT `g`.`tx_id`)
            FROM
                `tx_guide` `g`
            WHERE
                (`g`.`token_id` = `t`.`id`)) AS `tx_count`,
        (SELECT 
                COUNT(0)
            FROM
                `tx_guide` `g`
            WHERE
                (`g`.`token_id` = `t`.`id`)) AS `edge_count`,
        (SELECT 
                SUM(`g`.`amount`)
            FROM
                `tx_guide` `g`
            WHERE
                (`g`.`token_id` = `t`.`id`)) AS `total_volume`,
        (SELECT 
                COUNT(DISTINCT `g`.`from_address_id`)
            FROM
                `tx_guide` `g`
            WHERE
                (`g`.`token_id` = `t`.`id`)) AS `unique_senders`,
        (SELECT 
                COUNT(DISTINCT `g`.`to_address_id`)
            FROM
                `tx_guide` `g`
            WHERE
                (`g`.`token_id` = `t`.`id`)) AS `unique_receivers`,
        (SELECT 
                `g`.`tx_id`
            FROM
                `tx_guide` `g`
            WHERE
                (`g`.`token_id` = `t`.`id`)
            ORDER BY `g`.`block_time`
            LIMIT 1) AS `first_tx_id`,
        (SELECT 
                `g`.`tx_id`
            FROM
                `tx_guide` `g`
            WHERE
                (`g`.`token_id` = `t`.`id`)
            ORDER BY `g`.`block_time` DESC
            LIMIT 1) AS `last_tx_id`,
        (SELECT 
                MIN(`g`.`block_time`)
            FROM
                `tx_guide` `g`
            WHERE
                (`g`.`token_id` = `t`.`id`)) AS `first_guide_activity`,
        (SELECT 
                MAX(`g`.`block_time`)
            FROM
                `tx_guide` `g`
            WHERE
                (`g`.`token_id` = `t`.`id`)) AS `last_guide_activity`,
        FROM_UNIXTIME((SELECT 
                        MIN(`g`.`block_time`)
                    FROM
                        `tx_guide` `g`
                    WHERE
                        (`g`.`token_id` = `t`.`id`))) AS `first_guide_activity_utc`,
        FROM_UNIXTIME((SELECT 
                        MAX(`g`.`block_time`)
                    FROM
                        `tx_guide` `g`
                    WHERE
                        (`g`.`token_id` = `t`.`id`))) AS `last_guide_activity_utc`
    FROM
        (`tx_token` `t`
        JOIN `tx_address` `a` ON ((`a`.`id` = `t`.`mint_address_id`)));
