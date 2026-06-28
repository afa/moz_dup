all: lint # test
lint: rubocop

.PHONY: spec
spec: Gemfile.lock
	bundle exec rspec -r ./boot ${SPEC_PARAMS}&& Say success; Say done
fast-spec:
	bundle exec rspec -r boot --fail-fast=1 ${SPEC_PARAMS}&& Say success; Say done
test-flake:
	while rspec -r boot --fail-fast=1 ; do; done

Gemfile.lock: Gemfile
	bundle install
bundle: Gemfile.lock
rubocop: Gemfile.lock
	bundle exec rubocop --force-exclusion $(LINT_PATH)
cov:
	~/.local/bin/pycobertura show --format csv --delimiter : coverage/coverage.xml|sort -t: -nrk4 |awk -F : '{ if ( $$3 > 0 ) print $$1 "\t" $$4 "\t" $$5 }'
cov-full:
	~/.local/bin/pycobertura show --format csv --delimiter : coverage/coverage.xml|awk -F : '{ if ( $$3 > 0 ) print $$0 }'
# rspec: Gemfile.lock
# 	DATABASE_URL=postgres:///blog_test bundle exec rspec -r./boot $(TEST_PATH)
# run:
# 	thor gen25
# badfiles:
# 	find data/temp -size 0 |wc -l
# migrate:
# 	bundle exec sequel -m db/migrate postgres:///blog_devel
# 	bundle exec sequel -m db/migrate postgres:///blog_test
mysql:
	mysql moz
pg:
	psql postgres:///moz_dev
pg-test:
	psql postgres:///moz_test
databse:
	bundle exec sequel postgres:///moz_dev
server: Gemfile.lock
	bundle exec rackup
sh: Gemfile.lock
	bundle exec racksh
