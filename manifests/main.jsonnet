local k = import 'github.com/jsonnet-libs/k8s-libsonnet/1.23/main.libsonnet';
local deploy = k.apps.v1.deployment;
local container = k.core.v1.container;
local port = k.core.v1.containerPort;

deploy.new(name='sample', replicas=1, containers=[
  container.new('hello', 'hello:dev')
  + container.withPorts([port.newNamed(8000, 'http')])
  + container.resources.withRequests({ cpu: '100m', memory: '128Mi' })
  + container.resources.withLimits({ cpu: '1000m', memory: '1Gi' })
  + container.securityContext.withReadOnlyRootFilesystem(true)
  + container.securityContext.withRunAsNonRoot(true),
])
