FROM jupyter/base-notebook:lab-1.2.1

USER root

RUN apt-get update \
  && apt-get install -yq --no-install-recommends graphviz git \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

USER $NB_USER

RUN conda install --yes \
    -c conda-forge \
    python=3.8 \
    dask=2.23.0 \
    pandas=1.1.0 \
    pyarrow=1.0.0 \
    dask-ml=1.6.0 \
    dask-kubernetes \
    scikit-learn \
    s3fs \
    gcsfs \
    jupyter \
    jupyterlab \
    notebook \
    geopandas \
    fiona \
    geopy \
    descartes \
    matplotlib \
    seaborn \
    graphviz \
    python-graphviz \
    dask-labextension \
    && jupyter labextension install @jupyter-widgets/jupyterlab-manager dask-labextension@1.0.1 \
    && conda clean -tipsy \
    && jupyter lab clean \
    && jlpm cache clean \
    && npm cache clean --force \
    && find /opt/conda/ -type f,l -name '*.a' -delete \
    && find /opt/conda/ -type f,l -name '*.pyc' -delete \
    && find /opt/conda/ -type f,l -name '*.js.map' -delete \
    && find /opt/conda/lib/python*/site-packages/bokeh/server/static -type f,l -name '*.js' -not -name '*.min.js' -delete \
    && rm -rf /opt/conda/pkgs \
    && /opt/conda/bin/python -m pip install --no-deps cape-python validators==0.18.0 pycryptodome==3.9.8

USER root

# Create the /opt/app directory, and assert that Jupyter's NB_UID/NB_GID values
# haven't changed.
RUN mkdir /opt/app \
    && if [ "$NB_UID" != "1000" ] || [ "$NB_GID" != "100" ]; then \
        echo "Jupyter's NB_UID/NB_GID changed, need to update the Dockerfile"; \
        exit 1; \
    fi

# Copy over the example as NB_USER. Unfortuantely we can't use $NB_UID/$NB_GID
# in the `--chown` statement, so we need to hardcode these values.
COPY --chown=1000:100 examples/ /home/$NB_USER/examples
COPY prepare.sh /usr/bin/prepare.sh

USER $NB_USER

ENTRYPOINT ["tini", "--", "/usr/bin/prepare.sh"]
CMD ["start.sh", "jupyter", "lab"]
