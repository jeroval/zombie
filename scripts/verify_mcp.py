"""Exercise the real stdio MCP contract, including a rejected path escape."""

import asyncio
import json
import os
import sys
from pathlib import Path

from mcp.client import ClientSession
from mcp.client.stdio import StdioServerParameters, stdio_client

ROOT = Path(__file__).resolve().parents[1]


async def verify() -> dict:
    parameters = StdioServerParameters(
        command=sys.executable,
        args=[str(ROOT / "tools/gac_mcp/server.py")],
        env={**os.environ, "PYTHONUTF8": "1"},
    )
    async with stdio_client(parameters) as (reader, writer):
        async with ClientSession(reader, writer, read_timeout_seconds=60) as session:
            await session.initialize()
            listing = await session.list_tools()
            names = {tool.name for tool in listing.tools}
            expected = set(json.loads((ROOT / "tools/gac_mcp/policy.json").read_text())["tools"])
            if names != expected:
                raise RuntimeError(f"Unexpected MCP tools: {names ^ expected}")
            for name in ("blender_version", "godot_validate_smoke"):
                result = await session.call_tool(name, {})
                if result.is_error:
                    raise RuntimeError(f"{name}: {result}")
            rejected = await session.call_tool("ffmpeg_probe", {"relative_path": "../escape.wav"})
            if not rejected.is_error:
                raise RuntimeError("MCP did not reject a path outside the repository")
    return {
        "status": "PASS",
        "transport": "stdio",
        "tools": sorted(names),
        "calls": ["blender_version", "godot_validate_smoke"],
        "path_escape_rejected": True,
    }


if __name__ == "__main__":
    print(json.dumps(asyncio.run(verify()), indent=2))
