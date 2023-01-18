# Copyright 2023 Emprovise Inc. All Rights Reserved.
"""
Provides global values used across all modules.
"""
import os

from lib.logger import config_logger

DEFAULT_CONNECT_TIMEOUT_SECONDS = 60
DEFAULT_READ_TIMEOUT_SECONDS = 60
DEFAULT_MAX_RETRIES = 10
DEFAULT_LOG_LEVEL = 'INFO'
DEFAULT_ENABLE_XRAY = False
DEFAULT_AWS_REGION = 'us-west-2'
DEFAULT_STAGE = 'develop'


try:
    enable_xray = os.environ['ENABLE_XRAY'].lower() == 'true'
except KeyError:
    enable_xray = DEFAULT_ENABLE_XRAY

if enable_xray:
    # The xray_recorder import is needed for noinspection PyUnresolvedReferences
    from aws_xray_sdk.core import xray_recorder
    from aws_xray_sdk.core import patch_all
    patch_all()

try:
    connect_timeout_seconds = os.environ['CONNECT_TIMEOUT_SECONDS']
except KeyError:
    connect_timeout_seconds = DEFAULT_CONNECT_TIMEOUT_SECONDS

try:
    read_timeout_seconds = os.environ['READ_TIMEOUT_SECONDS']
except KeyError:
    read_timeout_seconds = DEFAULT_READ_TIMEOUT_SECONDS

try:
    max_retries = os.environ['MAX_RETRIES']
except KeyError:
    max_retries = DEFAULT_MAX_RETRIES

try:
    log_level = os.environ['LOG_LEVEL']
except KeyError:
    log_level = DEFAULT_LOG_LEVEL

try:
    aws_region = os.environ['REGION']
except KeyError:
    aws_region = DEFAULT_AWS_REGION

try:
    stage = os.environ['STAGE']
except KeyError:
    stage = DEFAULT_STAGE

logger = config_logger(log_level=log_level)
