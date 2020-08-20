# General config
cluster_name ?= dask-cluster
name ?= $(cluster_name)
config ?= values.yaml
cluster_admin ?= taugspurger@anaconda.com

# GCP settings
project_id ?= dask-demo-182016
zone ?= us-central1-b
num_nodes ?= 2
machine_type ?= n1-standard-4

cluster:
	gcloud container clusters create $(cluster_name) \
	    --num-nodes=$(num_nodes) \
	    --machine-type=$(machine_type) \
	    --zone=$(zone) \
		--enable-ip-alias \
		--enable-autoupgrade \
	    --enable-autorepair \
		--enable-autoscaling --min-nodes=0 --max-nodes=50 \
		--preemptible
	gcloud container clusters get-credentials $(cluster_name)

helm:
	helm repo add dask https://helm.dask.org
	helm repo update

dask:
	helm upgrade $(name) dask/dask --values=$(config) --install

print-ip:
	@echo jupyterlab: http://$$(kubectl get svc $(name)-jupyter -o jsonpath='{.status.loadBalancer.ingress[0].ip}'):80
	@echo scheduler : tcp://$$(kubectl get svc $(name)-scheduler -o jsonpath='{.status.loadBalancer.ingress[0].ip}'):8786
	@echo dashboard : http://$$(kubectl get svc $(name)-scheduler -o jsonpath='{.status.loadBalancer.ingress[0].ip}'):80/status

delete-helm:
	helm delete $(name) --purge
	# kubectl delete namespace $(name)

delete-cluster:
	gcloud container clusters delete $(cluster_name) --zone=$(zone)

docker: Dockerfile
	gcloud builds submit \
		--tag gcr.io/$(project_id)/dask-demo:$$(git rev-parse HEAD |cut -c1-6) \
		--timeout=1h \
		$(patsubst %/,%,$(dir $<))
	gcloud container images add-tag \
		gcr.io/$(project_id)/dask-demo:$$(git rev-parse HEAD |cut -c1-6) \
		gcr.io/$(project_id)/dask-demo:latest --quiet

values.yaml: values.yaml.tpl
	python make_values.py $$(git rev-parse HEAD |cut -c1-6)
