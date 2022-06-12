load('ext://restart_process', 'docker_build_with_restart')

config.define_bool('debug')
cfg = config.parse()
debug_mode = cfg.get('debug', False)

DOCKERFILE = '''FROM golang:alpine
WORKDIR /
COPY ./bin/hello /
CMD ["/hello"]
'''

build_cmd = 'CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o ./bin/hello main.go'
entrypoint=['/hello']

if debug_mode:
  DOCKERFILE = '''FROM golang:1.18
  RUN go install github.com/go-delve/delve/cmd/dlv@latest
  WORKDIR /
  COPY ./bin/hello /
  CMD ["/hello"]
  '''

  build_cmd = 'CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -gcflags "-N -l" -o ./bin/hello main.go'
  entrypoint=['/go/bin/dlv', '--listen=0.0.0.0:2345', "--accept-multiclient", '--api-version=2', '--headless=true', '--continue=true', 'exec', '/hello']


local_resource('build-hello', build_cmd, deps=['./main.go'])

docker_build_with_restart(
  'hello:latest',  # コンテナイメージ名
  '.',      # docker build する際のパス
  entrypoint=entrypoint,
  dockerfile_contents=DOCKERFILE,
  only=[
    # このファイルが変更されたときに docker build を実行する
    './bin/hello'
  ],
  live_update=[
    # ローカルの ./bin/hello とコンテナ内の /hello を同期する
    sync('./bin/hello', '/hello'),
  ]
)

watch_file('./manifests')
watch_settings(ignore=['./manifests/vendor']) # make previewするとvendorの変更が検知されてしまうのを無視。
yaml = local('DEV=true make preview')
k8s_yaml(yaml)
k8s_resource('sample', port_forwards=["8000:8000", "2345:2345"], resource_deps=['build-hello'])
