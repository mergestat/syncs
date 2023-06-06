# Syncs

Syncs are the new mode through which you could bring in data from external sources into `mergestat`. They are defined as container images, 
and executed as containerized processes using the [`podman`](http://podman.io) runtime. 

The main handler, defined at [`internal/jobs/sync/podman/podman.go`](https://github.com/mergestat/mergestat/blob/5f6bea5a3cbc5e8ab6b81ee6dd927bdd20151b8f/internal/jobs/sync/podman/podman.go) 
is responsible to pull, validate and execute the container images. It also defines a default environment where the execution happens. 
There are a couple of [`MERGESTAT_` prefixed](https://github.com/mergestat/mergestat/blob/5f6bea5a3cbc5e8ab6b81ee6dd927bdd20151b8f/internal/jobs/sync/podman/podman.go#L130-L137)
variables defined that are passed to the container. Additionally, user-defined variables [can also be passed to containers](https://github.com/mergestat/mergestat/blob/5f6bea5a3cbc5e8ab6b81ee6dd927bdd20151b8f/internal/jobs/sync/podman/podman.go#L139-L144).

Syncs make use of [Docker `LABEL`](https://docs.docker.com/config/labels-custom-metadata/) to convey meta-information about the sync to the handler. 
For example, the `com.mergestat.sync.clone` controls whether the repo should be cloned and mounted locally or not.

## List of environment variables

- `MERGESTAT_REPO_ID`: the unique `id` of the mergestat repository where the sync is running
- `MERGESTAT_REPO_URL`: the remote url of the mergestat repository
- `MERGESTAT_POSTGRES_URL`: url of the postgres database
- `MERGESTAT_PROVIDER_ID`: the unique `id` of the provider the current repository is associated to
- `MERGESTAT_AUTH_USERNAME`: the authentication username used for this provider
- `MERGESTAT_AUTH_TOKEN`: the authentication password / token used for this provider
- `MERGESTAT_PARAMS`: stringified JSON string representing additional user parameters

## List of labels

- `com.mergestat.sync.clone`: controls wheter the repository is cloned and mounted, or not
