"""Platform service - stateless API for deployment demonstrations."""

import os
import json
import logging
import signal
import sys
from datetime import datetime, timezone

from flask import Flask, jsonify


class StructuredLogger(logging.Formatter):
    def format(self, record):
        log_entry = {
            "timestamp": datetime.now(timezone.utc).isoformat(),
            "level": record.levelname,
            "logger": record.name,
            "message": record.getMessage(),
        }
        if record.exc_info:
            log_entry["exception"] = self.formatException(record.exc_info)
        return json.dumps(log_entry)


def configure_logging():
    handler = logging.StreamHandler(sys.stdout)
    handler.setFormatter(StructuredLogger())
    logger = logging.getLogger()
    logger.setLevel(logging.INFO)
    logger.addHandler(handler)
    return logger


app = Flask(__name__)
logger = configure_logging()

BUILD_SHA = os.getenv("COMMIT_SHA", "dev")
APP_NAME = os.getenv("SERVICE_NAME", "platform-api")
STAGE = os.getenv("ENVIRONMENT", "development")
PORT = int(os.getenv("PORT", "8080"))


def handle_shutdown(signum, frame):
    logger.info(f"shutdown_signal|signal={signum}")
    sys.exit(0)


@app.route("/health", methods=["GET"])
def health():
    return jsonify({"status": "OK"}), 200


@app.route("/", methods=["GET"])
def index():
    return "Hello Platform", 200


@app.route("/version", methods=["GET"])
def version():
    return jsonify({
        "build": BUILD_SHA,
        "service": APP_NAME,
        "stage": STAGE
    }), 200


@app.errorhandler(404)
def handle_not_found(e):
    return jsonify({"error": "not found"}), 404


@app.errorhandler(500)
def handle_server_error(e):
    logger.error(f"unhandled_exception|error={str(e)}")
    return jsonify({"error": "internal error"}), 500


if __name__ == "__main__":
    signal.signal(signal.SIGTERM, handle_shutdown)
    signal.signal(signal.SIGINT, handle_shutdown)
    
    logger.info(json.dumps({
        "status": "starting",
        "service": APP_NAME,
        "build": BUILD_SHA,
        "stage": STAGE
    }))
    
    app.run(
        host="0.0.0.0",
        port=PORT,
        debug=False,
        threaded=True
    )
