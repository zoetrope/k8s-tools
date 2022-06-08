local k = import "github.com/jsonnet-libs/k8s-libsonnet/1.23/main.libsonnet";
local deploy = k.apps.v1.deployment;
local container = k.core.v1.container;

deploy.new(name="sample", replicas=1, containers=[
    container.new("hello", "hello:latest")
])
