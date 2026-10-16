"""Project-scoped MCP, adapted from the Godot Asset Cloud scaffold."""

import sys
from pathlib import Path

from mcp.server import MCPServer
from mcp.server.mcpserver.exceptions import ToolError

sys.path.insert(0, str(Path(__file__).resolve().parents[2] / "scripts"))
from studio import (  # noqa: E402
    capabilities,
    convert_audio,
    godot_smoke,
    probe_audio,
    resolve_tool,
    run_checked,
)
from voice import generate_voice  # noqa: E402

mcp = MCPServer("gac-local-studio-zombie")


@mcp.tool()
def studio_capabilities() -> dict:
    """Verify local tools and return diagnostics without credentials."""
    return capabilities()


@mcp.tool()
def godot_validate_smoke() -> dict:
    """Import this game's assets and check its main scene headlessly."""
    return godot_smoke()


@mcp.tool()
def ffmpeg_probe(relative_path: str) -> dict:
    """Probe an existing project-local audio file."""
    try:
        return probe_audio(relative_path)
    except (ValueError, FileNotFoundError) as error:
        raise ToolError(str(error)) from error


@mcp.tool()
def audio_convert(input_path: str, output_path: str, sample_rate: int = 48000) -> dict:
    """Convert project-local audio to a new WAV/Ogg; refuse overwrites."""
    try:
        return convert_audio(input_path, output_path, sample_rate)
    except (ValueError, FileNotFoundError, FileExistsError) as error:
        raise ToolError(str(error)) from error


@mcp.tool()
def blender_version() -> dict:
    """Run the bounded Blender version check."""
    return run_checked([resolve_tool("blender"), "--version"], timeout=20)


@mcp.tool()
def voice_generate(
    text: str, output_path: str, voice: str = "siwis", speaker: int = 0, length_scale: float = 1.0
) -> dict:
    """Generate offline French speech in a new project-local WAV, with verified models."""
    try:
        return generate_voice(text, output_path, voice, speaker, length_scale)
    except (ValueError, FileNotFoundError, FileExistsError) as error:
        raise ToolError(str(error)) from error


if __name__ == "__main__":
    mcp.run()
