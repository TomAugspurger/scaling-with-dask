scheduler:
  image:
    repository: gcr.io/dask-demo-182016/dask-demo
    tag: {tag}
  resources:
    limits:
      cpu: 0.9
      memory: 3G
    requests:
      cpu: 0.9
      memory: 3G

worker:
  image:
    repository: gcr.io/dask-demo-182016/dask-demo
    tag: {tag}
  replicas: 20
  resources:
    limits:
      cpu: 2
      memory: 7G
    requests:
      cpu: 2
      memory: 7G

jupyter:
  image:
    repository: gcr.io/dask-demo-182016/dask-demo
    tag: {tag}
  password: 'sha1:aae8550c0a44:9507d45e087d5ee481a5ce9f4f16f37a0867318c'  # 'dask'
  resources:
    limits:
      cpu: 2
      memory: 6G
    requests:
      cpu: 2
      memory: 6G
