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

import os

from flask import Flask, request

import consts
import exceptions
import pubsub_publisher

""" Deploy App Engine Webhook Endpoint

    * Extract the Project ID and Destination Pub/Sub Topic
    * Initialize a Publisher used for sending data to Pub/Sub
    * Deploy a Flask App
"""
project_id = os.environ[consts.PROJECT_ID]
topic_name = os.environ[consts.PUBSUB_TOPIC]

publisher = pubsub_publisher.PubSubPublisher(project_id)
app = Flask(__name__)

@app.route('/', methods=['POST'])
def receive_data():
    return webhook_to_pubsub(request, wait_for_ack=False)

@app.errorhandler(exceptions.WebhookException)
def handle_invalid_usage(error):
    response = jsonify(error.to_dict())
    response.status_code = error.status_code
    return response

def webhook_to_pubsub(request, wait_for_ack=True) -> str:
    """ Return String response for HTTP Request Processing

        :param request: (flask.Request) The request object.
        <http://flask.pocoo.org/docs/1.0/api/#flask.Request>
        :param wait_for_ack: Bool if we need to wait for Pub/Sub ack
    """
    request_json = request.get_json(silent=True)
    if request_json is None:
        raise exceptions.WebhookException(consts.NO_DATA_MESSAGE, status_code=400)
    elif isinstance(request_json, list):
        for row in request_json:
            publisher.publish_data(topic_name, row, wait_for_ack=wait_for_ack)
    else:
        publisher.publish_data(topic_name, request_json, wait_for_ack=wait_for_ack)

    return str(request_json)
