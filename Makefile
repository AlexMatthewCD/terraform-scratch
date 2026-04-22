STG_DIR = env/staging

init-stg:
	terraform -chdir=$(STG_DIR) init

refresh-stg:
	terraform -chdir=$(STG_DIR) apply -refresh-only

plan-stg:
	terraform -chdir=$(STG_DIR) plan

apply-stg:
	terraform -chdir=$(STG_DIR) apply

console-stg:
	terraform -chdir=$(STG_DIR) console

destroy-stg:
	terraform -chdir=$(STG_DIR) destroy

fmt:
	terraform -chdir=$(STG_DIR) fmt
	terraform -chdir=modules/security fmt
	terraform -chdir=modules/vpc fmt
	terraform -chdir=modules/acm fmt
	terraform -chdir=modules/alb fmt
	terraform -chdir=modules/ec2 fmt
	terraform -chdir=modules/rds fmt
	terraform -chdir=modules/kms fmt

list-stg:
	terraform -chdir=$(STG_DIR) state list


