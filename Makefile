APP=tic_tac_toe
REBAR ?= $(shell which rebar 2>/dev/null || which ./rebar)

.PHONY: test

all: compile

get-deps:
	$(REBAR) get-deps

compile: get-deps
	$(REBAR) compile

app:
	$(REBAR) compile skip_deps=true

clean:
	$(REBAR) clean
	rm -rfv erl_crash.dump

clean-app:
	$(REBAR) clean skip_deps=true
	rm -rfv erl_crash.dump

distclean: clean
	rm -rfv ebin deps logs

start:
	exec erl -pa ebin deps/*/ebin -boot start_sasl -config priv/app.config -s tic_tac_toe_reloader -sname $(APP) -s $(APP)

teststart:
	exec erl -pa ebin deps/*/ebin -boot start_sasl -config priv/app.config -name tic_tac_toe@192.168.96.53 -s $(APP) -setcookie tic_tac_toe

test:
	mkdir -p .eunit
	$(REBAR) eunit skip_deps=true -v || true

dialyzer:
	dialyzer ebin deps/*/ebin -Wrace_conditions -Wunderspecs -Werror_handling


release:
	@mkdir -p /tmp/release_builder
	@rm -rf /tmp/release_builder/$(APP)
	@ln -sf $(PWD) /tmp/release_builder/$(APP)
	$(REBAR) generate force=1
	@rm -rf /tmp/release_builder/$(APP)

relclean:
	@rm -rf rel/$(APP)

install:
	rm -rf /opt/$(APP)
	cp -rf rel/$(APP) /opt/$(APP)
	chmod 644 /opt/$(APP)/logs
	mkdir -p /opt/$(APP)/priv/
	mkdir -p /etc/$(APP)/
	touch /etc/$(APP)/app.config
	test ! -e /opt/$(APP)/priv/extra.config && ln -s /etc/$(APP)/app.config /opt/$(APP)/priv/extra.config

uninstall:
	sudo rm -rf /opt/$(APP)

ci: compile test
