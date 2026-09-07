from flask import Blueprint, current_app, jsonify
from sqlalchemy import text

from backend.extensions import db


health_bp = Blueprint("health", __name__)


@health_bp.get("/health")
@health_bp.get("/app-health")
def health_check():
    # ALB health checks use this lightweight endpoint and do not depend on RDS.
    return jsonify({"status": "ok"}), 200


@health_bp.get("/health/db")
def database_health_check():
    # Keep the database check separate so a database issue is visible without
    # immediately removing every application target from the load balancer.
    try:
        db.session.execute(text("SELECT 1"))
    except Exception:
        current_app.logger.exception(
            "Database health check failed",
            extra={"event": "database_health_check_failed"},
        )
        return jsonify({"status": "error", "database": "unreachable", "message": "database check failed"}), 503

    return jsonify({"status": "ok", "database": "reachable"}), 200
