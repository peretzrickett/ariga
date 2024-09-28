
CREATE TABLE users (
	id SERIAL NOT NULL, 
	name VARCHAR, 
	email VARCHAR, 
	created_at TIMESTAMP WITH TIME ZONE DEFAULT now(), 
	updated_at TIMESTAMP WITH TIME ZONE, 
	PRIMARY KEY (id), 
	UNIQUE (email)
)

;

CREATE TABLE addresses (
	id SERIAL NOT NULL, 
	street VARCHAR, 
	city VARCHAR, 
	user_id INTEGER, 
	PRIMARY KEY (id), 
	FOREIGN KEY(user_id) REFERENCES users (id)
)

;
