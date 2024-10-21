LISP?=qlot exec ros run

build: clean
	$(LISP) \
		--eval "(asdf:load-asd #P\"$(shell pwd)/hotel-foxtrot.asd\")" \
		--eval '(ql:quickload :hotel-foxtrot)' \
		--eval '(asdf:make :hotel-foxtrot :force t)' \
		--quit

clean:
	rm -rf build

test:
	$(LISP) \
		--eval "(asdf:load-asd #P\"$(shell pwd)/hotel-foxtrot.asd\")" \
		--eval '(ql:quickload :hotel-foxtrot/tests)' \
		--eval '(asdf:test-system :hotel-foxtrot :force t)' \
		--quit
