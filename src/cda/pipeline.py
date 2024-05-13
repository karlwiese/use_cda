from functools import lru_cache
from typing import Callable

import yaml

from pathlib import Path

from openpyxl import load_workbook
from openpyxl.cell import Cell
from openpyxl.workbook import Workbook


SHEET_NAME_ENTITIES: str = "Entities"
SHEET_NAME_ATTRIBUTES: str = "Attributes"

DATA_TYPE_MAPPING_POSTGRES: dict[str, str] = {
    "Text 10": "VARCHAR(10)",
    "Text 15": "VARCHAR(15)",
    "Text 20": "VARCHAR(20)",
    "Text 25": "VARCHAR(25)",
    "Text 40": "VARCHAR(40)",
    "Text 50": "VARCHAR(50)",
    "Text 80": "VARCHAR(80)",
    "Text 100": "VARCHAR(100)",
    "Boolean": "BOOLEAN",
    "hcp.language.Picklist": "CHAR(2)",
    "hcp.country.Picklist": "CHAR(2)",
    "hcp.state.Picklist": "VARCHAR(6)",
    "hcp.hcp_type.Picklist": "CHAR(4)",
    "hcp.spec_1.Picklist": "VARCHAR(4)",
    "hcp.all_spec.Multivalue Picklist": "VARCHAR(4)[]",
    "hcp.spec_group_1.Picklist": "CHAR(2)",
    "hcp.all_spec_group.Multivalue Picklist": "CHAR(2)[]",
    "hcp.degree_1.Picklist": "VARCHAR(4)",
    "hcp.all_degree.Multivalue Picklist": "VARCHAR(4)[]",
    "hcp.status.Picklist": "VARCHAR(4)",
    "hcp.level.Picklist": "SMALLINT",
    "hcp.adopter_type.Picklist": "VARCHAR(4)",
    "address.country.Picklist": "CHAR(2)",
    "address.state.Picklist": "VARCHAR(6)",
    "address.status.Picklist": "VARCHAR(4)",
    "Entity (HCP)": "INT",
}

type Kernel = dict[str, dict[str, dict[str, str | list[dict[str, str]]]]]


def run() -> None:
    input_folder = Path().cwd() / "input"
    output_folder = Path().cwd() / "output"

    for file in input_folder.glob("*.xlsx"):
        wb = load_workbook(filename=file)

        kernel = _init_kernel(wb)
        kernel = _add_attributes(wb, kernel)
        kernel = _add_picklists(wb, kernel)

        output_subfolder = output_folder / file.parts[-1].replace(".xlsx", "").replace(
            ".", "_"
        ).replace("-", "_")
        output_subfolder.mkdir(exist_ok=True)

        _creat_output(output_subfolder, kernel)


def _init_kernel(wb: Workbook) -> Kernel:
    return _sheet_iterator(
        wb, SHEET_NAME_ENTITIES, {SHEET_NAME_ENTITIES: {}}, _add_entity
    )


def _add_attributes(wb: Workbook, kernel: Kernel) -> Kernel:
    for entity in kernel[SHEET_NAME_ENTITIES].values():
        entity[SHEET_NAME_ATTRIBUTES] = []
    return _sheet_iterator(wb, SHEET_NAME_ATTRIBUTES, kernel, _add_attribute)


def _add_picklists(wb: Workbook, kernel: Kernel) -> Kernel:
    return kernel


def _creat_output(output_folder: Path, kernel: Kernel) -> None:
    with open(output_folder / "yaml.yaml", "w") as yaml_file:
        yaml.dump(dict(kernel), yaml_file)

    postgresql_query = _build_postgresql_query(kernel)
    with open(output_folder / "postgres.sql", "w") as postgres_file:
        postgres_file.write(postgresql_query)


def _sheet_iterator(
    wb: Workbook, sheet_name: str, kernel: Kernel, add_row: Callable
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

        kernel = add_row(row, kernel, fields)

    return kernel


def _add_entity(row: tuple[Cell], kernel: Kernel, fields: list[str]):
    kernel[SHEET_NAME_ENTITIES][_parse_cell_value(row[0])] = {
        field: _parse_cell_value(cell)
        for field, cell in zip(fields[1:], row[1 : len(fields)])
    }

    return kernel


def _add_attribute(row: tuple[Cell], kernel: Kernel, fields: list[str]):
    if row[0].value in kernel[SHEET_NAME_ENTITIES].keys():
        kernel[SHEET_NAME_ENTITIES][row[0].value][SHEET_NAME_ATTRIBUTES].append(
            {
                field: _parse_cell_value(cell)
                for field, cell in zip(fields[1:], row[1 : len(fields)])
            }
        )

    return kernel


def _parse_cell_value(cell: Cell) -> str | None:
    if isinstance(cell.value, str):
        return None if cell.value == "N/A" else cell.value.strip()
    elif cell.value is None:
        return None
    else:
        raise ValueError(f"Found unexpected type {type(cell)} for value {cell}")


def _build_postgresql_query(kernel: Kernel) -> str:
    query = ""
    for name, definition in kernel[SHEET_NAME_ENTITIES].items():
        name = _escape_sql_keyword(name.lower())
        query += f"""DROP TABLE IF EXISTS {name}
;
CREATE TABLE {name} (
    {_build_sql_columns(definition[SHEET_NAME_ATTRIBUTES], name)}
)
;
COMMENT ON TABLE {name} IS '{_build_sql_table_comment(definition)}'
;
{_build_sql_column_comments(definition[SHEET_NAME_ATTRIBUTES], name)}
;

"""

    return query


def _build_sql_columns(attributes: list[dict], table_name: str) -> str:
    return ",\n    ".join(
        [
            f"{_escape_sql_keyword(attribute['Name'].lower())} {
                DATA_TYPE_MAPPING_POSTGRES[
                    table_name + '.' + attribute['Name'].lower() + '.' + attribute['Data Type']
                ]
                if attribute['Data Type'] in ("Picklist", "Multivalue Picklist") else
                DATA_TYPE_MAPPING_POSTGRES[attribute['Data Type']]
            }"
            for attribute in attributes
        ]
    )


def _build_sql_column_comments(attributes: list[dict], table_name: str) -> str:
    return "\n;\n".join(
        [
            f"COMMENT ON COLUMN {table_name}.{attribute['Name'].lower()} IS"
            f" '{_build_sql_comment(attribute, exclude=('Name', 'Data Type'))}'"
            for attribute in attributes
        ]
    )


def _build_sql_table_comment(definition: dict) -> str:
    return _build_sql_comment(definition, (SHEET_NAME_ATTRIBUTES,))


def _build_sql_comment(definition: dict, exclude: tuple = tuple()) -> str:
    return ", ".join(
        [
            f"{key}: {value.replace("'", "''")}"
            for key, value in definition.items()
            if key not in exclude and value is not None
        ]
    )


def _escape_sql_keyword(string: str) -> str:
    sql_keywords = _get_sql_keywords()

    if string.upper() in sql_keywords:
        string = f'"{string}"'

    return string


@lru_cache
def _get_sql_keywords() -> tuple[str, ...]:
    with open(Path.cwd() / "resources" / "sql_keywords.yaml") as stream:
        return tuple(yaml.safe_load(stream)["sql_keywords"])
