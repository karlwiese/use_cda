from typing import Callable

import yaml

from pathlib import Path

from openpyxl import load_workbook
from openpyxl.cell import Cell
from openpyxl.workbook import Workbook


SHEET_NAME_ENTITIES = "Entities"
SHEET_NAME_ATTRIBUTES = "Attributes"

type Kernel = dict[str, dict[str, dict[str, str | list[dict[str, str]]]]]


def run() -> None:
    input_folder = Path().cwd() / "input"
    output_folder = Path().cwd() / "output"

    for file in input_folder.glob("*.xlsx"):
        wb = load_workbook(filename=file)

        kernel = init_kernel(wb)
        kernel = add_attributes(wb, kernel)
        kernel = add_picklists(wb, kernel)

        output_subfolder = output_folder / file.parts[-1].replace(".xlsx", "").replace(
            ".", "_"
        ).replace("-", "_")
        output_subfolder.mkdir(exist_ok=True)

        save_yaml(output_subfolder, kernel)


def init_kernel(wb: Workbook) -> Kernel:
    return sheet_iterator(
        wb, SHEET_NAME_ENTITIES, {SHEET_NAME_ENTITIES: {}}, udf_entities
    )


def add_attributes(wb: Workbook, kernel: Kernel) -> Kernel:
    for entity in kernel[SHEET_NAME_ENTITIES].values():
        entity[SHEET_NAME_ATTRIBUTES] = []
    return sheet_iterator(wb, SHEET_NAME_ATTRIBUTES, kernel, udf_attributes)


def add_picklists(wb: Workbook, kernel: Kernel) -> Kernel:
    return kernel


def sheet_iterator(
    wb: Workbook, sheet_name: str, kernel: Kernel, udf: Callable
) -> Kernel:
    idx = -1
    fields = None
    for i, row in enumerate(wb[sheet_name].rows):
        if sum(cell.value is not None for cell in row) == 1:
            idx = i
            continue

        if i == idx + 1:
            fields = [item.value for item in row if item.value is not None]
            continue

        if fields is None:
            raise RuntimeError("Did not find a row that defines the fields.")

        kernel = udf(row, kernel, fields)

    return kernel


def udf_entities(row: tuple[Cell], kernel: Kernel, fields: list[str]):
    kernel[SHEET_NAME_ENTITIES][parse_cell_value(row[0])] = {
        field: parse_cell_value(cell)
        for field, cell in zip(fields[1:], row[1 : len(fields)])
    }

    return kernel


def udf_attributes(row: tuple[Cell], kernel: Kernel, fields: list[str]):
    if row[0].value in kernel[SHEET_NAME_ENTITIES].keys():
        kernel[SHEET_NAME_ENTITIES][row[0].value][SHEET_NAME_ATTRIBUTES].append(
            {
                field: parse_cell_value(cell)
                for field, cell in zip(fields[1:], row[1 : len(fields)])
            }
        )

    return kernel


def parse_cell_value(cell: Cell) -> str | None:
    if isinstance(cell.value, str):
        return None if cell.value == "N/A" else cell.value.strip()
    elif cell.value is None:
        return None
    else:
        raise ValueError(f"Found unexpected type {type(cell)} for value {cell}")


def save_yaml(output_folder: Path, kernel: Kernel) -> None:
    with open(output_folder / "_.yaml", "w") as yaml_file:
        yaml.dump(dict(kernel), yaml_file)
