load('ext://restart_process', 'docker_build_with_restart')

DOCKERFILE = '''FROM golang:1.18
RUN go install github.com/go-delve/delve/cmd/dlv@latest
WORKDIR /
COPY ./bin/hello /
CMD ["/hello"]
'''

build_cmd = 'CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -gcflags "-N -l" -o ./bin/hello main.go'

local_resource('build-hello', build_cmd, deps=['./main.go'])

docker_build_with_restart(
  'hello',  # コンテナイメージ名
  '.',      # docker build する際のパス
  entrypoint=['/go/bin/dlv', '--listen=0.0.0.0:40000', "--accept-multiclient", '--api-version=2', '--headless=true', '--continue=true', 'exec', '/hello'],
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
watch_settings(ignore=['./manifests/vendor']) # jb install するたびに tilt の更新処理が走ってしまうので。
yaml = local('make preview')
k8s_yaml(yaml)
k8s_resource('sample', port_forwards=[8000, 40000], resource_deps=['build-hello'])
