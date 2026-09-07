from backend.extensions import db


def test_health_check(client):
    response = client.get("/health")

    assert response.status_code == 200
    assert response.get_json() == {"status": "ok"}


def test_app_health_alias(client):
    response = client.get("/app-health")

    assert response.status_code == 200
    assert response.get_json() == {"status": "ok"}


def test_database_health_check(client):
    response = client.get("/health/db")

    assert response.status_code == 200
    assert response.get_json() == {"status": "ok", "database": "reachable"}


def test_database_health_check_hides_exception_details(client, monkeypatch):
    def fail_execute(_statement):
        raise RuntimeError("password=do-not-return-this")

    monkeypatch.setattr(db.session, "execute", fail_execute)

    response = client.get("/health/db")

    assert response.status_code == 503
    assert response.get_json() == {
        "status": "error",
        "database": "unreachable",
        "message": "database check failed",
    }
    assert "password" not in response.get_data(as_text=True)
