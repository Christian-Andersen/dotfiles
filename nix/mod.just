setup:
    nix build '.#homeConfigurations.christian.activationPackage'
    ./result/activate

activate:
    nh home switch .

update:
    nh home switch -u .

build:
    nix build
    podman load < result

vul:
    nix build
    vulnix ./result

