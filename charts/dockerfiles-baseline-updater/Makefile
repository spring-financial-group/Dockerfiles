CHART_REPO := oci://jx3mqubebuild.azurecr.io/spring-financial-group/charts
NAME := dockerfiles-baseline-updater

build: clean
	helm lint .

template:
	helm template $(NAME) .

clean:
	rm -rf $(NAME)-*.tgz

release: clean build
	helm package .
	helm push $(NAME)-$(shell sed -n 's/^version: //p' Chart.yaml).tgz $(CHART_REPO)
