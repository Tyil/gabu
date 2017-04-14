DESTDIR?=/usr/local

configuration:
	mkdir -p $(DESTDIR)/etc
	cp --no-clobber config.yaml $(DESTDIR)/etc/gabu.yaml
	chmod 644 $(DESTDIR)/etc/gabu.yaml

install: configuration
	mkdir -p $(DESTDIR)/bin
	install -m 755 gabu $(DESTDIR)/bin/gabu

remove:
	rm $(DESTDIR)/bin/gabu

