load('ext://restart_process', 'docker_build_with_restart')

DOCKERFILE = '''FROM golang:alpine
WORKDIR /
COPY ./bin/hello /
CMD ["/hello"]
'''

build_cmd = 'CGO_ENABLED=0 go build -o ./bin/hello main.go'

local_resource('build-hello', build_cmd, deps=['./main.go'])

docker_build_with_restart(
  'hello',  # コンテナイメージ名
  '.',      # docker build する際のパス
  entrypoint=['/hello'],
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
yaml = local('make preview')
k8s_yaml(yaml)
k8s_resource('sample', port_forwards=8000, resource_deps=['build-hello'])
