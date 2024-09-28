CREATE MATERIALIZED VIEW user_addresses AS
SELECT
    u.id AS user_id,
    u.name,
    COUNT(a.id) AS address_count
FROM
    users u
LEFT JOIN
    addresses a ON u.id = a.user_id
GROUP BY
    u.id, u.name;
