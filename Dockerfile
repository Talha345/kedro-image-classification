ARG BASE_IMAGE=python:3.10-slim
FROM $BASE_IMAGE as runtime-environment

# install essential libraries like gcc and make
RUN apt-get update && apt-get install -y build-essential

# install project requirements
#COPY src/requirements.txt /tmp/requirements.txt
#RUN pip install --no-cache -r /tmp/requirements.txt && rm -f /tmp/requirements.txt && pip install -U kedro-viz

COPY pyproject.toml /pyproject.toml
RUN pip install poetry && poetry install && rm -f /pyproject.toml

# add kedro user
ARG KEDRO_UID=999
ARG KEDRO_GID=0
RUN groupadd -f -g ${KEDRO_GID} kedro_group && \
useradd -m -d /home/kedro_docker -s /bin/bash -g ${KEDRO_GID} -u ${KEDRO_UID} kedro_docker

WORKDIR /home/kedro_docker
USER kedro_docker

FROM runtime-environment

# copy the whole project except what is in .dockerignore
ARG KEDRO_UID=999
ARG KEDRO_GID=0
COPY --chown=${KEDRO_UID}:${KEDRO_GID} . .

EXPOSE 8888

CMD ["kedro", "run"]
