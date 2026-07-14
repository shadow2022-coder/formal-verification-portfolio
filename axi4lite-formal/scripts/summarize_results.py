
"""Summarize generated SymbiYosys task results."""

from pathlib import Path


PROJECT_ROOT = Path(__file__).resolve().parent.parent
FORMAL_DIR = PROJECT_ROOT / "formal"

TASKS = {
    "Safety proof": FORMAL_DIR / "axi4lite_prove" / "status",
    "Cover analysis": FORMAL_DIR / "axi4lite_cover" / "status",
    "Assumption audit": FORMAL_DIR / "axi4lite_assumption_audit" / "status",
}


def read_status(status_file: Path) -> str:
    """Return the task status, or NOT RUN when no result exists."""
    if not status_file.exists():
        return "NOT RUN"

    value = status_file.read_text(encoding="utf-8").strip()
    return value if value else "UNKNOWN"


def main() -> None:
    print("AXI4-Lite Verification Results")
    print("=" * 38)

    for task_name, status_file in TASKS.items():
        status = read_status(status_file)
        print(f"{task_name:<20}: {status}")

    waveform = PROJECT_ROOT / "build" / "axi4lite.vcd"
    simulation_status = "GENERATED" if waveform.exists() else "NOT RUN"
    print(f"{'Simulation waveform':<20}: {simulation_status}")

    print()
    print("Expected:")
    print("  Safety proof     : PASS")
    print("  Cover analysis   : PASS")
    print("  Assumption audit : FAIL (intentional)")


if __name__ == "__main__":
    main()