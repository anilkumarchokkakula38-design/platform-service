import json
import pytest
from app.main import app


@pytest.fixture
def client():
    app.config["TESTING"] = True
    with app.test_client() as client:
        yield client


def test_health_endpoint(client):
    response = client.get("/health")
    assert response.status_code == 200
    data = json.loads(response.data)
    assert data["status"] == "OK"


def test_root_endpoint(client):
    response = client.get("/")
    assert response.status_code == 200
    assert response.data == b"Hello Platform"


def test_version_endpoint(client):
    response = client.get("/version")
    assert response.status_code == 200
    data = json.loads(response.data)
    assert "build" in data
    assert "service" in data
    assert "stage" in data


def test_404_not_found(client):
    response = client.get("/nonexistent")
    assert response.status_code == 404
    data = json.loads(response.data)
    assert data["error"] == "not found"
