"""
JSON Schema Validator Library for Robot Framework
Validates JSON payloads against Draft-07 / Draft-2020-12 specifications with rich error reporting.
"""

import json
from pathlib import Path
from typing import Any, Dict, Union
import jsonschema
from jsonschema import Draft7Validator
from robot.api import logger


class JsonSchemaValidator:
    """Robot Framework Library for validating JSON dictionaries against schema definitions."""

    ROBOT_LIBRARY_SCOPE = "GLOBAL"

    def __init__(self):
        self._schema_cache: Dict[str, Dict[str, Any]] = {}

    def _resolve_schema(self, schema: Union[str, Path, Dict[str, Any]]) -> Dict[str, Any]:
        """Loads and caches schema from a file path or returns dictionary if already parsed."""
        if isinstance(schema, dict):
            return schema

        schema_path = Path(schema)
        if not schema_path.is_absolute():
            # Try relative to workspace
            candidate = Path.cwd() / schema_path
            if candidate.exists():
                schema_path = candidate

        path_str = str(schema_path.resolve())
        if path_str in self._schema_cache:
            return self._schema_cache[path_str]

        if not schema_path.exists():
            raise FileNotFoundError(f"JSON Schema file not found: {schema_path}")

        with open(schema_path, "r", encoding="utf-8") as f:
            data = json.load(f)
            self._schema_cache[path_str] = data
            return data

    def validate_json_schema(self, data: Union[str, Dict[str, Any]], schema: Union[str, Path, Dict[str, Any]]) -> bool:
        """
        Validates JSON `data` against `schema` (file path or dictionary).
        Throws an AssertionError with full validation failure paths if schema contract is violated.
        """
        if isinstance(data, str):
            try:
                payload = json.loads(data)
            except Exception as e:
                raise AssertionError(f"Failed to parse payload as JSON string: {e}")
        else:
            payload = data

        schema_dict = self._resolve_schema(schema)
        validator = Draft7Validator(schema_dict)

        errors = sorted(validator.iter_errors(payload), key=lambda e: e.path)
        if errors:
            error_details = []
            for err in errors:
                path = " -> ".join([str(p) for p in err.path]) if err.path else "root"
                error_details.append(f"  * [{path}] {err.message}")
            formatted = "\n".join(error_details)
            msg = f"JSON Schema Validation Failed with {len(errors)} error(s):\n{formatted}"
            logger.error(msg)
            raise AssertionError(msg)

        logger.info(f"JSON Schema Validation PASSED for schema: {schema_dict.get('title', 'Untitled Schema')}")
        return True
