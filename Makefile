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
	exec erl -pa ebin deps/*/ebin -boot start_sasl -config priv/app.config -s tic_tac_toe_reloader -s $(APP)

test:
	mkdir -p .eunit
	$(REBAR) eunit skip_deps=true -v || true

dialyzer:
	dialyzer ebin deps/*/ebin -Wrace_conditions -Wunderspecs -Werror_handling

release:
	mkdir -p /tmp/release_builder/ && \
	rm -rfv /tmp/release_builder/$(APP) && \
	ln -sf $(PWD) /tmp/release_builder/$(APP) && \
	$(REBAR) generate && \
	rm -rfv /tmp/release_builder/$(APP)

relclean:
	rm -rfv rel/$(APP)

ci: compile test
