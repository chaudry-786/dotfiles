from dash import Dash, dcc, html, Input, Output
import plotly.express as px
import dash_bootstrap_components as dbc
from dash_bootstrap_templates import load_figure_template
import pandas as pd
import glob
import os

load_figure_template("darkly")


def read_and_group_key_logs(pattern, frequency="D"):
    all_data = []
    files = glob.glob(pattern)

    for file in files:
        df = pd.read_csv(file, delimiter="~", names=["datetime", "key", "description"])
        df["datetime"] = pd.to_datetime(
            df["datetime"].str.strip("[]"), format="%Y-%m-%d %H:%M:%S", errors="coerce"
        )
        all_data.append(df)

    if all_data:
        combined_df = pd.concat(all_data, ignore_index=True)
        combined_df = combined_df.dropna(subset=["datetime"])

        if combined_df.empty:
            raise ValueError("No valid data found in logs after dropping NaT values.")

        grouped_df = (
            combined_df.groupby([pd.Grouper(key="datetime", freq=frequency), "key"])
            .size()
            .reset_index(name="count")
        )
        return grouped_df
    else:
        raise ValueError("No data found in logs.")


app = Dash(__name__, external_stylesheets=[dbc.themes.DARKLY])

execution_environment = "vscode"
KEY_LOGS = os.path.join(
    os.environ.get("HOME"), f"vim_analysis/{execution_environment}_key_logs*.txt"
)

try:
    key_logs_df = read_and_group_key_logs(KEY_LOGS, frequency="D")
    top_keys = key_logs_df["key"].unique()[:10]
    min_date, max_date = key_logs_df["datetime"].min(), key_logs_df["datetime"].max()
except ValueError as e:
    print(e)
    key_logs_df = pd.DataFrame()

app.layout = dbc.Container(
    [
        html.H1("Key Usage Over Time", className="text-center"),
        dcc.DatePickerRange(
            id="date-range-picker",
            start_date=min_date,
            end_date=max_date,
            display_format="YYYY-MM-DD",
            style={"margin": "10px"},
        ),
        dcc.Dropdown(
            id="key-dropdown",
            options=[{"label": key, "value": key} for key in top_keys],
            value=top_keys.tolist() if len(top_keys) > 0 else [],
            multi=True,
        ),
        dcc.Graph(id="usage-graph", style={"height": "80vh"}),
    ],
    fluid=True,
)


@app.callback(
    Output("usage-graph", "figure"),
    [
        Input("key-dropdown", "value"),
        Input("date-range-picker", "start_date"),
        Input("date-range-picker", "end_date"),
    ],
)
def update_graph(selected_keys, start_date, end_date):
    if not selected_keys:
        return px.line(title="No keys selected")

    filtered_df = key_logs_df[
        (key_logs_df["key"].isin(selected_keys))
        & (key_logs_df["datetime"] >= start_date)
        & (key_logs_df["datetime"] <= end_date)
    ]

    fig = px.line(
        filtered_df,
        x="datetime",
        y="count",
        color="key",
        title="Key Usage Over Time",
        line_shape="spline",
        markers=True,
    )

    return fig


if __name__ == "__main__":
    app.run_server(debug=True)
