DESTDIR?=/usr/local

configuration:
	mkdir -p $(DESTDIR)/etc
	cp --no-clobber config.yaml $(DESTDIR)/etc/gabu.yaml
	chmod 644 $(DESTDIR)/etc/gabu.yaml

install: configuration
	mkdir -p $(DESTDIR)/bin
	install -m 755 src/gabu.pl $(DESTDIR)/bin/gabu

remove:
	rm $(DESTDIR)/bin/gabu

test:
	perlcritic --profile .perlcriticrc src/*.pl
	sh tests/style.sh

