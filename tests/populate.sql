-- Insert sample users
INSERT INTO public.users (name, email, created_at)
VALUES
('Alice Smith', 'alice@example.com', now()),
('Bob Johnson', 'bob@example.com', now()),
('Carol Williams', 'carol@example.com', now());

-- Insert sample addresses
INSERT INTO public.addresses (street, city, user_id)
VALUES
('123 Maple Street', 'Springfield', (SELECT id FROM public.users WHERE email = 'alice@example.com')),
('456 Oak Avenue', 'Springfield', (SELECT id FROM public.users WHERE email = 'alice@example.com')),
('789 Pine Road', 'Shelbyville', (SELECT id FROM public.users WHERE email = 'bob@example.com')),
('101 Elm Street', 'Ogdenville', (SELECT id FROM public.users WHERE email = 'carol@example.com')),
('202 Birch Boulevard', 'Ogdenville', (SELECT id FROM public.users WHERE email = 'carol@example.com'));
