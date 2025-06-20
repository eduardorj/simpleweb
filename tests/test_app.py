from flask import Flask
from flask.testing import FlaskClient
import pytest
from app import app as flask_app

@pytest.fixture
def app():
    yield flask_app

@pytest.fixture
def client(app: Flask):
    return app.test_client()

def test_landing_page(client: FlaskClient):
    """Test the landing page."""
    response = client.get('/')
    assert response.status_code == 200
    assert b"Welcome to the Flask Test Landing Page!" in response.data