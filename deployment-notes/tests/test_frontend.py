import pytest
from werkzeug.exceptions import NotFound

import backend


class FrontendTestConfig:
    TESTING = True
    SERVE_FRONTEND = True
    SQLALCHEMY_DATABASE_URI = "sqlite:///:memory:"
    SQLALCHEMY_TRACK_MODIFICATIONS = False


def test_frontend_route_rejects_path_traversal(monkeypatch):
    monkeypatch.setattr(backend, "FRONTEND_DIST_DIR", backend.Path("/frontend/dist"))
    app = backend.create_app(FrontendTestConfig)
    send_calls = []

    def record_send(*args, **kwargs):
        send_calls.append((args, kwargs))

    monkeypatch.setattr(backend, "send_from_directory", record_send)

    with app.test_request_context():
        with pytest.raises(NotFound):
            app.view_functions["serve_frontend"]("../outside.txt")

    assert send_calls == []


def test_frontend_route_serves_assets_and_keeps_spa_fallback(tmp_path, monkeypatch):
    dist_dir = tmp_path / "dist"
    asset_dir = dist_dir / "assets"
    asset_dir.mkdir(parents=True)
    (asset_dir / "app.js").write_text("console.log('ok')", encoding="utf-8")
    (dist_dir / "index.html").write_text("<main>Deployment Notes</main>", encoding="utf-8")

    monkeypatch.setattr(backend, "FRONTEND_DIST_DIR", dist_dir)
    app = backend.create_app(FrontendTestConfig)
    client = app.test_client()

    asset_response = client.get("/assets/app.js")
    spa_response = client.get("/dashboard/settings")

    assert asset_response.status_code == 200
    assert asset_response.get_data(as_text=True) == "console.log('ok')"
    assert spa_response.status_code == 200
    assert spa_response.get_data(as_text=True) == "<main>Deployment Notes</main>"
