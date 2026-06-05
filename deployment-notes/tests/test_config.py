from backend import config


def test_resolve_database_url_prefers_direct_env(monkeypatch):
    monkeypatch.setenv("DEPLOYMENT_NOTES_DATABASE_URL", "mysql+pymysql://direct")
    monkeypatch.setenv("DEPLOYMENT_NOTES_DATABASE_URL_SSM_PARAM", "/app/db/url")
    monkeypatch.setattr(
        config,
        "get_ssm_parameter",
        lambda name: "mysql+pymysql://from-ssm",
    )

    assert config.resolve_database_url() == "mysql+pymysql://direct"


def test_resolve_database_url_uses_ssm_parameter_name(monkeypatch):
    requested_params = []

    def fake_get_ssm_parameter(name):
        requested_params.append(name)
        return "mysql+pymysql://from-ssm"

    monkeypatch.delenv("DEPLOYMENT_NOTES_DATABASE_URL", raising=False)
    monkeypatch.setenv("DEPLOYMENT_NOTES_DATABASE_URL_SSM_PARAM", "/app/db/url")
    monkeypatch.setattr(config, "get_ssm_parameter", fake_get_ssm_parameter)

    assert config.resolve_database_url() == "mysql+pymysql://from-ssm"
    assert requested_params == ["/app/db/url"]


def test_resolve_database_url_keeps_local_sqlite_fallback(monkeypatch, tmp_path):
    monkeypatch.delenv("DEPLOYMENT_NOTES_DATABASE_URL", raising=False)
    monkeypatch.delenv("DEPLOYMENT_NOTES_DATABASE_URL_SSM_PARAM", raising=False)
    monkeypatch.setenv("DEPLOYMENT_NOTES_ENV", "development")

    assert config.resolve_database_url(tmp_path).startswith("sqlite:///")
