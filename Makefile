gen:
	./generate_init.sh

initdb:
	cat patch/init.sql | psql -U postgres

.PHONY:all
all: gen initdb