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

GENERATOR="substructure"
TAG=""
while getopts g:t: flag
do
    case "${flag}" in
        g) GENERATOR=${OPTARG};;
        t) TAG=${OPTARG};;
    esac
done
echo "GENERATOR: $GENERATOR";
echo "TAG: $TAG";

TIMESTAMP="$(date +"%Y-%m-%d-%H-%M-%S")"
JOB_NAME="${GENERATOR}-${TIMESTAMP}-${TAG}"
OUTPUT_PATH="gs://research-graph-synthetic/${USER}/sampling/${JOB_NAME}"
TEMP_LOCATION="gs://research-graph-synthetic/temp"
echo "OUTPUT_PATH: ${OUTPUT_PATH}"

FULL_JOB_NAME=$(echo "${USER}-${JOB_NAME}" | tr '_' '-')

ENTRYPOINT="python3 /app/beam_benchmark_main.py \
  --runner=DataflowRunner \
  --project=research-graph \
  --region=us-east1 \
  --max_num_workers=1000 \
  --temp_location="${TEMP_LOCATION}" \
  --gin_config=/app/configs/${GENERATOR}_config.gin \
  --output="${OUTPUT_PATH}" \
  --job_name="${FULL_JOB_NAME}" \
  --experiments=use_monitoring_state_manager \
  --experiments=enable_execution_details_collection \
  --experiment=use_runner_v2 \
  --worker_harness_container_image=gcr.io/research-graph/research-graph-synthetic:latest"

echo "entrypoint: ${ENTRYPOINT}"

docker-compose run --entrypoint "${ENTRYPOINT}" research-graph-synthetic
  
  