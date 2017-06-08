ssh:
	mkdir -p ssh
	ssh-keygen -f ssh/deployer -t rsa -b 4096 -N ''

plan:
	terraform plan

apply: ssh
	ssh-add ssh/deployer
	terraform apply

destroy:
	terraform destroy -f