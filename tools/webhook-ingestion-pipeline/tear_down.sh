#!/bin/bash

# Copyright 2020 Google Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Destroy Deployment
cd terraform/ || exit
bq rm -f --project_id="${TF_VAR_project_id}" webhook.webhook_data
bq rm -f --project_id="${TF_VAR_project_id}" "${TF_VAR_dead_letter_queue}"
terraform destroy -auto-approve

cd .. || exit

# Tear Down Dataflow
DF_JOBS=$(gcloud dataflow jobs list --status=active --region="${TF_VAR_webhook_region}" --project="${TF_VAR_project_id}" | grep 'webhook-job-' | awk '{print $1;}')
gcloud dataflow jobs cancel "${DF_JOBS}" --region="${TF_VAR_webhook_region}" --project="${TF_VAR_project_id}"
