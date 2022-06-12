local k = import 'github.com/jsonnet-libs/k8s-libsonnet/1.23/main.libsonnet';
local deploy = k.apps.v1.deployment;
local container = k.core.v1.container;
local port = k.core.v1.containerPort;

function(dev=false)
  # 開発時はlatestタグのイメージを利用する
  local tag = if dev then 'latest' else 'v1.0.0';

  local hello = container.new('hello', 'hello:' + tag)
                + container.withPorts([port.newNamed(8000, 'http')]);

  local opt = if dev then {} else
    # 開発時はtiltやdlvがメモリをたくさん使うのでlimitsを設定しない。
    # tiltはrootでの実行を要求するのでsecurityContextを設定しない。
    container.resources.withRequests({ cpu: '100m', memory: '128Mi' })
    + container.resources.withLimits({ cpu: '100m', memory: '128Mi' })
    + container.securityContext.withReadOnlyRootFilesystem(true)
    + container.securityContext.withRunAsNonRoot(true);

  deploy.new(name='sample', replicas=1, containers=[hello + opt])
