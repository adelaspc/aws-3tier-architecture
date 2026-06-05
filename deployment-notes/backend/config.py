import os
from pathlib import Path

from dotenv import load_dotenv


load_dotenv()


def truthy_env(value):
    return str(value or "").strip().lower() in {"1", "true", "yes", "on"}


def current_environment():
    return os.getenv("DEPLOYMENT_NOTES_ENV", "").strip().lower()


def should_serve_frontend():
    configured_value = os.getenv("DEPLOYMENT_NOTES_SERVE_FRONTEND")
    if configured_value is not None:
        return truthy_env(configured_value)

    return current_environment() in {"local", "development", "test"}


def get_ssm_parameter(name):
    import boto3

    region_name = os.getenv("AWS_REGION") or os.getenv("AWS_DEFAULT_REGION")
    client = boto3.client("ssm", region_name=region_name)
    response = client.get_parameter(Name=name, WithDecryption=True)
    return response["Parameter"]["Value"]


def resolve_database_url(instance_path=None):
    database_url = os.getenv("DEPLOYMENT_NOTES_DATABASE_URL")
    if database_url:
        return database_url

    database_url_param = os.getenv("DEPLOYMENT_NOTES_DATABASE_URL_SSM_PARAM")
    if database_url_param:
        return get_ssm_parameter(database_url_param)

    app_env = current_environment()
    if app_env in {"local", "development", "test"}:
        database_path = Path(instance_path or "instance") / "deployment_notes.db"
        return f"sqlite:///{database_path.resolve()}"

    raise RuntimeError(
        "DEPLOYMENT_NOTES_DATABASE_URL or DEPLOYMENT_NOTES_DATABASE_URL_SSM_PARAM "
        f"must be set when DEPLOYMENT_NOTES_ENV is '{app_env or 'unset'}'"
    )


class Config:
    SQLALCHEMY_DATABASE_URI = os.getenv("DEPLOYMENT_NOTES_DATABASE_URL")
    SQLALCHEMY_TRACK_MODIFICATIONS = False
    SERVE_FRONTEND = should_serve_frontend()
    LOG_LEVEL = os.getenv("DEPLOYMENT_NOTES_LOG_LEVEL", "INFO")

    @staticmethod
    def init_app(app):
        if not app.config.get("SQLALCHEMY_DATABASE_URI"):
            app.config["SQLALCHEMY_DATABASE_URI"] = resolve_database_url(app.instance_path)
