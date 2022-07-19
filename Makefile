.PHONY:gen
gen:
	sh generate_init.sh

.PHONY:patch
patch:
	cat patch/init.sql | psql -U postgres

.PHONY:drop
drop:
	cat patch/drop.sql | psql -U postgres

.PHONY:feed
feed:
	cat patch\feed.sql | psql -U postgres -d reedygreedy

.PHONY:repatch
repatch: drop patch

.PHONY:all
all: gen patch