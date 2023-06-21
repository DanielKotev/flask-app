#!/usr/bin/python 
from flask import Flask
from flask import render_template
import os
import boto3
import json

app = Flask(__name__)
env = os.getenv("ENV")


def get_env_secret():
    client = boto3.client('secretsmanager')
    kms = boto3.client('kms', region_name='eu-central-1')
    response = client.get_secret_value(
        SecretId='password'
    )
    env_password = json.loads(response['SecretString'])
    if env == 'prod':
        return (env_password['env_prod'])
    if env == 'stage':
        return (env_password['env_stage'])
    if env == 'dev':
        return (env_password['env_dev'])


@app.route("/env")
def home(): return f"This is {env} and the password is {get_env_secret()}"


@app.route("/picture")
def pic():
    return render_template('index.html')


@app.route("/pragmatic")
def salvador():
    return f"hello from {env}"


if __name__ == "__main__":
    app.run(host='0.0.0.0', debug=True)
