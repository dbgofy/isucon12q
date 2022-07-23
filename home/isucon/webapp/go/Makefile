.PHONY: deploy
deploy:
	$(MAKE) logrotate
	sudo -u isucon docker compose -f /home/isucon/webapp/docker-compose-go.yml up -d --build

.PHONY: logrotate
logrotate:
	> /var/log/mysql/mysql-slow.log
	> /var/log/nginx/access.log

.PHONY: bench
bench:
	cat /var/log/nginx/access.log | /root/go/bin/kataribe -f /root/kataribe.toml | slackcat -c kataribe
	mysqldumpslow -s t /var/log/mysql/mysql-slow.log | slackcat -c slowlog

isuports: test go.mod go.sum *.go cmd/isuports/*
	go build -o isuports ./cmd/isuports

test:
	go test -v ./...
