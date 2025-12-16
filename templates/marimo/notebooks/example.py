# /// script
# requires-python = ">=3.12"
# dependencies = ["marimo"]
# ///
"""Example marimo notebook. Edit with: marimo edit notebooks/example.py"""

import marimo

__generated_with = "0.13.6"
app = marimo.App(width="medium")


@app.cell
def _():
    import marimo as mo

    return (mo,)


if __name__ == "__main__":
    app.run()
