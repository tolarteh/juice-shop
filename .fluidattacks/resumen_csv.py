"""Escribe en el resumen del job cuántos hallazgos trae el CSV de Fluid Attacks.

Uso: python3 .fluidattacks/resumen_csv.py <escáner> <archivo.csv>
"""
import csv
import os
import sys
from collections import Counter

nombre, ruta = sys.argv[1], sys.argv[2]
resumen = os.environ.get("GITHUB_STEP_SUMMARY", "/dev/stdout")

with open(resumen, "a", encoding="utf-8") as out:
    if not os.path.isfile(ruta):
        out.write(f"### {nombre}: no se generó `{ruta}`\n")
        sys.exit(0)

    with open(ruta, newline="", encoding="utf-8", errors="replace") as f:
        filas = list(csv.DictReader(f))

    out.write(f"### {nombre}: {len(filas)} hallazgos exportados en `{ruta}`\n\n")

    # Si el CSV trae una columna de severidad, se resume por nivel.
    columnas = filas[0].keys() if filas else []
    col_sev = next((c for c in columnas if "severity" in c.lower() or "severidad" in c.lower()), None)
    if col_sev:
        out.write(f"| {col_sev} | Hallazgos |\n|---|---|\n")
        for valor, n in Counter(r[col_sev] for r in filas).most_common():
            out.write(f"| {valor} | {n} |\n")
        out.write("\n")
