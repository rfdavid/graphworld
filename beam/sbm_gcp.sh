#!/bin/bash
# Copyright 2021 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


TIMESTAMP="$(date +"%Y-%m-%d-%H-%M-%S")"
OUTPUT_PATH="gs://research-graph-synthetic/${USER}/sampling/${TIMESTAMP}"
TEMP_LOCATION="gs://research-graph-synthetic/temp"
echo "OUTPUT_PATH: ${OUTPUT_PATH}"

NSAMPLES="${1:-10000}"
echo "NSAMPLES: ${NSAMPLES}"

JOB_NAME=$(echo "${USER}-${TIMESTAMP}" | tr '_' '-')

ENTRYPOINT="python3 /app/beam_sbm.py \
  --runner=DataflowRunner \
  --project=research-graph \
  --region=us-east1 \
  --max_num_workers=256 \
  --temp_location="${TEMP_LOCATION}" \
  --output="${OUTPUT_PATH}" \
  --nsamples="${NSAMPLES}" \
  --job_name="${JOB_NAME}" \
  --experiments=use_monitoring_state_manager \
  --experiments=enable_execution_details_collection \
  --experiment=use_runner_v2 \
  --worker_harness_container_image=gcr.io/research-graph/research-graph-synthetic:latest"

echo "entrypoint: ${ENTRYPOINT}"

docker-compose run --entrypoint "${ENTRYPOINT}" research-graph-synthetic
  
  