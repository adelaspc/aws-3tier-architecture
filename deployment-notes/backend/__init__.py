from pathlib import Path

from flask import Flask, abort, send_from_directory
from werkzeug.exceptions import NotFound
from werkzeug.security import safe_join

from backend.api import register_blueprints
from backend.config import Config
from backend.extensions import db, migrate
from backend.logging import configure_json_logging


FRONTEND_DIST_DIR = Path(__file__).resolve().parents[1] / "frontend" / "dist"


def create_app(config_class=Config):
    # The catch-all route below owns static files and SPA fallback behavior.
    # Disabling Flask's implicit static route avoids two competing /<path> rules.
    app = Flask(__name__, static_folder=None)
    Path(app.instance_path).mkdir(parents=True, exist_ok=True)
    app.config.from_object(config_class)
    init_app = getattr(config_class, "init_app", None)
    if callable(init_app):
        init_app(app)
    configure_json_logging(app)

    db.init_app(app)
    migrate.init_app(app, db)

    register_blueprints(app)

    # In AWS, Nginx owns the frontend and proxies API traffic to this service.
    # Serving the SPA here is only a convenience for local development.
    if not app.config.get("SERVE_FRONTEND"):
        return app

    dist_dir = FRONTEND_DIST_DIR

    @app.route("/", defaults={"path": ""})
    @app.route("/<path:path>")
    def serve_frontend(path):
        if path:
            # Reject traversal before attempting the SPA fallback. Flask's
            # send_from_directory performs the same containment check when it
            # serves the file; keeping it explicit here prevents an unsafe path
            # from being treated as a client-side route.
            if safe_join(str(dist_dir), path) is None:
                abort(404)

            try:
                return send_from_directory(dist_dir, path)
            except NotFound:
                pass

        if dist_dir.is_dir():
            # Unknown paths fall back to index.html so client-side routes work.
            return send_from_directory(dist_dir, "index.html")

        return {"error": "Frontend build not available"}, 404

    return app
