up:
	docker-compose up -d

restart: 
	docker-compose down --volumes;
	docker-compose up -d