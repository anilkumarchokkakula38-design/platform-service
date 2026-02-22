import os
import json
import pytest

os.environ.setdefault("TESTING", "true")
os.environ.setdefault("SERVICE_NAME", "platform-service")
os.environ.setdefault("ENVIRONMENT", "test")
os.environ.setdefault("COMMIT_SHA", "unknown")


@pytest.fixture(scope="session")
def test_config():
    """Provide test configuration"""
    return {
        "service_name": "platform-service",
        "environment": "test",
        "port": 8080,
    }
