from sqlalchemy import MetaData
from models import Base
from sqlalchemy.schema import CreateTable, CreateIndex
from sqlalchemy.dialects import postgresql

metadata = Base.metadata

with open('orm_schema.sql', 'w') as f:
    for table in metadata.sorted_tables:
        # Generate CREATE TABLE statement
        ddl = str(CreateTable(table).compile(dialect=postgresql.dialect())) + ';\n'
        f.write(ddl)

        # Generate CREATE INDEX statements
        for index in table.indexes:
            ddl = str(CreateIndex(index).compile(dialect=postgresql.dialect())) + ';\n'
            f.write(ddl)
