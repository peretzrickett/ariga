-- Create function to update 'updated_at' timestamp
CREATE OR REPLACE FUNCTION public.update_user_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to update 'updated_at' on 'users' table
CREATE TRIGGER trg_update_user_updated_at
BEFORE UPDATE ON public.users
FOR EACH ROW
EXECUTE FUNCTION public.update_user_updated_at();

-- Create materialized view
CREATE MATERIALIZED VIEW IF NOT EXISTS public.user_addresses AS
SELECT
  u.email AS user_email,
  u.id AS user_id,
  u.name,
  COUNT(a.id) AS address_count
FROM
  public.users u
LEFT JOIN
  public.addresses a ON u.id = a.user_id
GROUP BY
  u.id, u.name;
