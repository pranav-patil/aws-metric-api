"""
This module provides common logging configuration
"""

import logging
import sys
import time

from pythonjsonlogger import jsonlogger

def config_logger(log_level, propagate=False):
    logging.Formatter.converter = time.gmtime
    logger = logging.getLogger('aws-metric-api')
    logger.setLevel(log_level)

    if log_level == 'INFO' or log_level == 'DEBUG':
        stream_handler = logging.StreamHandler(sys.stdout)
        formatter = logging.Formatter(fmt='%(message)s')
        stream_handler.setFormatter(formatter)
        logger.addHandler(stream_handler)
    else:
        json_handler = logging.StreamHandler()
        formatter = jsonlogger.JsonFormatter(
            fmt='%(asctime)s %(levelname)s %(name)s %(module)s %(pathname)s %(funcName)s %(lineno)d %(message)s',
            datefmt='%Y-%m-%dT%H:%M:%S.%03dZ'
        )
        json_handler.setFormatter(formatter)
        logger.handlers.clear()
        logger.addHandler(json_handler)

    logger.propagate = propagate
    return logger