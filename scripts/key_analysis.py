import pandas as pd
import duckdb
import re
import glob
from pyvis.network import Network
import webbrowser
import numpy as np


def generate_key_hierarchies(df, key_column="key", description_column="desc"):

    def split_key_into_hierarchy(key):
        # Use regex to separate out parts that are within <...> and treat them as separate entities
        parts = re.split(r"(<[^>]+>)", key)

        hierarchy = []
        for part in parts:
            if part:
                if part.startswith("<") and part.endswith(">"):
                    hierarchy.append(part)
                else:
                    hierarchy.extend(list(part))
        return hierarchy

    key_hierarchies = {}

    # Iterate over each row in the DataFrame to build the hierarchy based on key and description
    for index, row in df.iterrows():
        full_key = row[key_column]
        description = row[description_column]

        key_hierarchies[full_key] = {
            "heirarchy": split_key_into_hierarchy(full_key),
            "desc": description,
        }

    return key_hierarchies


def read_key_logs_as_df(pattern):
    all_data = []

    files = glob.glob(pattern)

    for file in files:
        df = pd.read_csv(file, delimiter="~", names=["datetime", "key", "description"])
        all_data.append(df)
    if all_data:
        return pd.concat(all_data, ignore_index=True)
    else:
        raise ValueError("No data found in logs.")


import numpy as np


def aggregate_logs_df(logs_df, max_levels=5):
    # Calculate the usage counts
    usage_counts = duckdb.query(
        """
        SELECT key, COUNT(*) AS usage_count
        FROM logs_df
        GROUP BY key
        """
    ).to_df()

    # Apply logarithmic scaling to usage counts
    usage_counts["log_usage"] = np.log1p(
        usage_counts["usage_count"]
    )  # Use log1p for log(1 + x)

    # Determine the bucket levels based on the scaled values
    min_log = usage_counts["log_usage"].min()
    max_log = usage_counts["log_usage"].max()
    bucket_size = (max_log - min_log) / max_levels

    # Create the bucket level assignment based on log usage
    def assign_bucket(log_usage):
        for i in range(max_levels):
            if log_usage <= min_log + (i + 1) * bucket_size:
                return i + 1
        return max_levels

    # Apply the bucket assignment
    usage_counts["bucket_level"] = usage_counts["log_usage"].apply(assign_bucket)

    # Prepare the final output DataFrame
    output_df = usage_counts[["key", "usage_count", "bucket_level"]]

    return output_df


def combine_mappings_with_metric(key_hierarchies, agg_df):
    for _, row in agg_df.iterrows():
        key = row["key"]
        count = row["usage_count"]

        if key in key_hierarchies:
            key_hierarchies[key]["usage_count"] = count
    return key_hierarchies


def create_key_hierarchy_network(key_hierarchies):
    net = Network(
        height="1000px",
        width="100%",
        bgcolor="#222222",
        font_color="white",
        directed=True,
        filter_menu=True,
    )

    for full_key, hierarchy_data in key_hierarchies.items():
        current_key = ""
        usage_count = hierarchy_data.get("usage_count", 0)
        bucket_level = hierarchy_data.get("bucket_level", 1)  # Default to level 1

        # Size scaling based on bucket level
        node_size = bucket_level * 20

        for i, key in enumerate(hierarchy_data["heirarchy"]):
            current_key += f"-{key}"

            # Add node with size based on bucket level
            net.add_node(
                current_key,
                label=key,
                title=f"Usage Count: {usage_count}",
                level=i + 1,
                value=node_size,
            )

            if i > 0:
                net.add_edge(current_key[: -len(key) - 1], current_key)

    # Smooth edges for better visualization
    net.set_edge_smooth("continuous")

    # Generate the HTML file for the graph
    net.force_atlas_2based(gravity=-90)
    output_file = "simple_key_hierarchy_graph.html"
    net.write_html(output_file)

    return output_file


# Define file paths
place_of_execution = "vscode"
ALL_KEYMAPPINGS = "/home/sabah/vim_analysis/all_mappings.csv"
KEY_LOGS = f"/home/sabah/vim_analysis/{place_of_execution}_key_logs*.txt"

df = pd.read_csv(
    ALL_KEYMAPPINGS, delimiter="~", names=["mode", "key", "desc", "rhs_type"]
)

key_hierarchies = generate_key_hierarchies(df)
logs_df = read_key_logs_as_df(KEY_LOGS)
agg_df = aggregate_logs_df(logs_df)


key_hierarchies = combine_mappings_with_metric(key_hierarchies, agg_df)
netowrk_file = create_key_hierarchy_network(key_hierarchies)
webbrowser.open(netowrk_file)
