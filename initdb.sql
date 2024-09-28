-- Create table for users
CREATE TABLE IF NOT EXISTS public.users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL,
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_at TIMESTAMPTZ
);

-- Ensure the email column is unique
CREATE UNIQUE INDEX IF NOT EXISTS idx_users_email ON public.users(email);

-- Create table for addresses
CREATE TABLE IF NOT EXISTS public.addresses (
    id SERIAL PRIMARY KEY,
    street VARCHAR(255) NOT NULL,
    city VARCHAR(255) NOT NULL,
    user_id INT NOT NULL,
    CONSTRAINT fk_user FOREIGN KEY (user_id)
        REFERENCES public.users(id)
        ON DELETE CASCADE
);

-- Add any necessary custom functions, triggers, or materialized views
-- Create function to update 'updated_at' timestamp
CREATE OR REPLACE FUNCTION update_user_updated_at()
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
EXECUTE FUNCTION update_user_updated_at();

-- Create materialized view to aggregate user addresses
CREATE MATERIALIZED VIEW IF NOT EXISTS public.user_addresses AS
SELECT
  u.id AS user_id,
  u.name,
  COUNT(a.id) AS address_count
FROM
  public.users u
LEFT JOIN
  public.addresses a ON u.id = a.user_id
GROUP BY
  u.id, u.name;
