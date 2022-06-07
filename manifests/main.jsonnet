local k = import "github.com/jsonnet-libs/k8s-libsonnet/1.23/main.libsonnet";

{
    local deploy = k.apps.v1.deployment,
    local container = k.core.v1.container,

    deployment: deploy.new(name="sample", replicas=1, containers=[
        container.new("nginx", "nginx:latest")
    ])
}
