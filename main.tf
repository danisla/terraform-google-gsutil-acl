# Copyright 2017 Google Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

data "external" "module-gsutil-acl" {
  program = ["${path.module}/gsutil_acl.sh"]

  query {
    url         = "${var.url}"
    action      = "${var.enabled ? var.action : "noop"}"
    entity      = "${var.entity}"
    entity_type = "${var.entity_type}"
  }
}

locals {
  url         = "${lookup(data.external.module-gsutil-acl.result, "url")}"
  action      = "${lookup(data.external.module-gsutil-acl.result, "action")}"
  entity_type = "${lookup(data.external.module-gsutil-acl.result, "entity_type")}"
  entity      = "${lookup(data.external.module-gsutil-acl.result, "entity")}"
  acl         = "${lookup(data.external.module-gsutil-acl.result, "acl")}"
}
