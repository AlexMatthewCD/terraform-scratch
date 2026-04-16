STG_DIR = env/staging

init-stg:
	terraform -chdir=$(STG_DIR) init

plan-stg:
	terraform -chdir=$(STG_DIR) plan

apply-stg:
	terraform -chdir=$(STG_DIR) apply

fmt:
	terraform -chdir=$(STG_DIR) fmt
	terraform -chdir=modules/security fmt
	terraform -chdir=modules/vpc fmt

list-stg:
	terraform -chdir=$(STG_DIR) state list


