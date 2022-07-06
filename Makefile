gen:
	sh ./generate_init.sh

patch:
	cat patch/init.sql | psql -U postgres

.PHONY:all
all: gen patch