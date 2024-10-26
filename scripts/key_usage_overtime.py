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

        original_count = combined_df.shape[0]
        # Drop duplicates and calculate dropped rows
        combined_df = combined_df.drop_duplicates()
        print(f"Number of rows dropped due to duplicates: {original_count - combined_df.shape[0]}")

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

# Read and group key logs
key_logs_df = read_and_group_key_logs(KEY_LOGS, frequency="D")
if key_logs_df.empty:
    raise ValueError("No valid data found after processing key logs.")

all_keys = key_logs_df["key"].unique().tolist()
top_keys = ( key_logs_df["key"].value_counts().nlargest(10).index.tolist())
min_date, max_date = key_logs_df["datetime"].min(), key_logs_df["datetime"].max()

# App layout with pre-selected top keys
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
            options=[
                {
                    "label": html.Span(
                        [key],
                        style={
                            "color": "#343a40",
                            "font-size": 20,
                        },
                    ),
                    "value": key,
                }
                for key in all_keys
            ],
            value=top_keys,
            multi=True,
            placeholder="Select keys",
            style={
                "backgroundColor": "#e9f7fe",
                "color": "#0056b3",
                "border": "2px solid #6c757d",
                "borderRadius": "4px",
            },
        ),
        dbc.Button(
            "Show Percentage",
            id="percentage-button",
            n_clicks=0,
            color="primary",
            className="mb-3",
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
        Input("percentage-button", "n_clicks"),
    ],
)
def update_graph(selected_keys, start_date, end_date, n_clicks):
    # Time range filter.
    date_filtered_df = key_logs_df[
        (key_logs_df["datetime"] >= start_date) & (key_logs_df["datetime"] <= end_date)
    ]

    # Selected key filter
    filtered_df = date_filtered_df[date_filtered_df["key"].isin(selected_keys)]

    y_axis_label = "Key Usage Count"
    # Work out percentage
    if n_clicks % 2 == 1:
        daily_totals = date_filtered_df.groupby("datetime")["count"].transform("sum")
        filtered_df["count"] = (filtered_df["count"] / daily_totals) * 100
        y_axis_label = "Usage Percentage (%)"


    fig = px.line(
        filtered_df,
        x="datetime",
        y="count",
        color="key",
        title="Key Usage Over Time",
        labels={"count": y_axis_label},
        line_shape="spline",
        markers=True,
    )

    return fig


if __name__ == "__main__":
    app.run_server(debug=True)
