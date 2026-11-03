# Raccourcis — tout passe par les scripts, que la CI joue aussi.
.PHONY: miroir tester tester-vite fmt

miroir:
	scripts/construire-le-miroir.sh

tester:
	scripts/tester.sh

# Sans reconstruire le fournisseur (miroir déjà là).
tester-vite:
	scripts/tester.sh --sans-construire

fmt:
	tofu fmt -recursive
