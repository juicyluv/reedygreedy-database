.PHONY:gen
gen:
	sh generate_init.sh

.PHONY:patch
patch:
	cat patch/init.sql | psql -U postgres

.PHONY:drop
drop:
	cat patch/drop.sql | psql -U postgres

.PHONY:repatch
repatch: drop patch

.PHONY:all
all: gen patch