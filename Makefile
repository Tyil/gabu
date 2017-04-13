DESTDIR?=/usr/local

install:
	install -m 755 gabu $(DESTDIR)/bin/gabu

remove:
	rm $(DESTDIR)/bin/gabu

