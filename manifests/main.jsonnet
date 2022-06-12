local k = import 'github.com/jsonnet-libs/k8s-libsonnet/1.23/main.libsonnet';
local deploy = k.apps.v1.deployment;
local container = k.core.v1.container;
local port = k.core.v1.containerPort;
local affinity = k.core.v1.affinity;

function(dev=false)
  // 開発時はlatestタグのイメージを利用する
  local hello = container.new('hello', 'hello:' + if dev then 'latest' else 'v1.0.0');

  local opts = if dev == false then
    container.withPorts([port.newNamed(8000, 'http')])
    + container.resources.withRequests({ cpu: '100m', memory: '128Mi' })
    + container.resources.withLimits({ cpu: '100m', memory: '128Mi' })
    + container.securityContext.withReadOnlyRootFilesystem(true)
    + container.securityContext.withRunAsNonRoot(true)
  else
    // デバッグ用のポートを追加する
    container.withPorts([port.newNamed(8000, 'http'), port.newNamed(2345, 'debug')]);
  // 開発時はtiltやdlvがメモリをたくさん使うのでlimitsを設定しない
  // tiltはrootでの実行を要求するのでsecurityContextを設定しない

  deploy.new(name='sample', replicas=1, containers=[hello + opts])
