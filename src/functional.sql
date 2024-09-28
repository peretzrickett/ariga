CREATE OR REPLACE FUNCTION update_user_updated_at()
RETURNS TRIGGER AS $$
    BEGIN
        NEW.updated_at = NOW();
        RETURN NEW;
    END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_update_user_updated_at
BEFORE UPDATE ON users
    FOR EACH ROW
    EXECUTE FUNCTION update_user_updated_at();

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
