IMAGE="thmzlt/nix-actions-runner"

build:
	docker build -t $(IMAGE) .

shell:
	docker-compose run --rm $(IMAGE) bash

start:
	docker-compose up --remove-orphans
