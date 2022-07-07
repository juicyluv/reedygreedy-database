.PHONY:gen
gen:
	sh generate_init.sh

.PHONY:patch
patch:
	cat patch/init.sql | psql -U postgres

.PHONY:all
all: gen patch