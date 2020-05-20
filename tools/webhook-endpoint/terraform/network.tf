# Copyright 2019 Google Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

resource "google_project_service" "data_pipeline_api" {
  project = var.project_id
  service = "compute.googleapis.com"
  disable_on_destroy = false
}

# resource "google_compute_network" "data_pipeline" {
#   project                 = var.project_id
#   name                    = var.network_name
#   auto_create_subnetworks = false

#   depends_on = [google_project_service.data_pipeline_api]
# }