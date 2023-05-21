


enable:
	cd script && \
	./nanit-permission.sh enable

disable:
	cd script && \
	./nanit-permission.sh disable

install:
	./post_main.d/install-nanit-permissions.sh
