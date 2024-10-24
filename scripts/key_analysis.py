import os
import pandas as pd
import argparse
import duckdb
import re
import glob
from pyvis.network import Network
import webbrowser
import numpy as np
from datetime import datetime, timedelta
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
    for _, row in df.iterrows():
        full_key = row[key_column]
        description = row[description_column]

        key_hierarchies[full_key] = {
            "heirarchy": split_key_into_hierarchy(full_key),
            "desc": description,
        }

    return key_hierarchies


def read_key_logs_as_df(pattern, time_period_in_days=None):
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
        print(f"Length of entire data { len(combined_df)}")
        if time_period_in_days is not None:
            cutoff_date = datetime.now() - timedelta(days=time_period_in_days)
            combined_df = combined_df[combined_df["datetime"] >= cutoff_date]
        print(f"Returning rows { len( combined_df ) }")
        return combined_df
    else:
        raise ValueError("No data found in logs.")


def aggregate_logs_df(logs_df, max_levels=5):
    # Calculate the usage counts
    usage_counts = duckdb.query(
        """
        SELECT key, COUNT(*) AS usage_count
        FROM logs_df
        GROUP BY key
        """
    ).to_df()
    print(f"Total active keys {len(usage_counts)}")

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


def combine_mappings_with_metric(key_hierarchies, agg_df, active_only):
    for _, row in agg_df.iterrows():
        key = row["key"]
        count = row["usage_count"]
        bucket_level = row["bucket_level"]

        if key in key_hierarchies:
            key_hierarchies[key]["usage_count"] = count
            key_hierarchies[key]["bucket_level"] = bucket_level
        else:
            print(f"{ key } not found in all mappings")

    # If active_only is True, filter out keys with usage_count of 0
    if active_only:
        key_hierarchies = {
            k: v for k, v in key_hierarchies.items() if v.get("usage_count", 0) > 0
        }

    return key_hierarchies


def get_node_color(bucket_level, usage_count):
    if usage_count == 0:
        return "#FFFACD"

    green_shades = {
        1: "#A8E6A8",
        2: "#76D976",
        3: "#43CC43",
        4: "#2EB82E",
        5: "#1F7A1F",
    }

    # Check explicitly if the bucket_level exists in green_shades
    if bucket_level in green_shades:
        return green_shades[bucket_level]
    else:
        raise ValueError(
            f"Invalid bucket_level: {bucket_level}. Expected a value between 1 and 5."
        )


def add_node(network, node):
    current_key = ""
    usage_count = node.get("usage_count", 0)
    bucket_level = node.get("bucket_level", 1)
    description = node.get("desc", None)

    scale = 30
    node_size = bucket_level * scale

    for i, key in enumerate(node["heirarchy"]):
        current_key += f"-{key}"

        # Add node with size based on bucket level
        if i == len(node["heirarchy"]) - 1:
            network.add_node(
                current_key,
                label=key,
                title=f"Usage Count: {usage_count}\n Desc: {description} \n Bucket level: {bucket_level}",
                level=i + 1,
                value=int(scale / 2) if usage_count == 0 else node_size,
                color=get_node_color(bucket_level, usage_count),
            )
        else:
            network.add_node(
                current_key,
                label=key,
                title=f"Parent",
                level=i + 1,
                value=int(scale / 2),
                color="#D3D3D3",
            )

        if i > 0:
            network.add_edge(current_key[: -len(key) - 1], current_key)

    return network


def create_key_hierarchy_network(key_hierarchies):
    net = Network(
        height="1000px",
        width="100%",
        bgcolor="#222222",
        font_color="white",
        directed=True,
        # filter_menu=True,
    )

    for _, hierarchy_data in key_hierarchies.items():
        net = add_node(net, hierarchy_data)

    # Smooth edges for better visualization
    net.set_edge_smooth("continuous")

    # Generate the HTML file for the graph
    net.force_atlas_2based(gravity=-90)
    output_file = "simple_key_hierarchy_graph.html"
    net.write_html(output_file)

    return output_file


# Function to parse time range (you can expand this logic as needed)
def parse_time_range(time_range):
    if time_range.endswith("w"):
        return int(time_range[:-1]) * 7  # Convert weeks to days
    elif time_range.endswith("m"):
        return int(time_range[:-1]) * 30  # Approximate months to days
    elif time_range.endswith("y"):
        return int(time_range[:-1]) * 365  # Convert years to days
    else:
        raise ValueError(f"Invalid time range format: {time_range}. Use 1w, 2m, 1y.")


if __name__ == "__main__":
    # Set up command-line argument parser
    parser = argparse.ArgumentParser(description="Process key mappings and logs.")

    # Add the time range flag
    parser.add_argument(
        "-t",
        "--time_range",
        type=str,
        default="6m",
        help="Specify the time range (e.g., 1w, 2m, 1y) to filter key logs.",
    )

    # Whether to show all keys or only active keys.
    parser.add_argument(
        "--display",
        type=str,
        choices=["all", "active"],
        default="active",
        help="Choose whether to display 'all' key mappings or 'active' ones within the time range.",
    )

    args = parser.parse_args()
    if args.time_range:
        time_period_in_days = parse_time_range(args.time_range)
        print(f"Filtering logs for the last {time_period_in_days} days.")
    else:
        time_period_in_days = None

    # Define file paths
    execution_environment = "vscode"
    ALL_KEYMAPPINGS = os.environ.get("HOME") + "/vim_analysis/all_mappings.csv"
    KEY_LOGS = (
        os.environ.get("HOME") + f"/vim_analysis/{execution_environment}_key_logs*.txt"
    )

    all_keymappings_df = pd.read_csv(
        ALL_KEYMAPPINGS, delimiter="~", names=["mode", "key", "desc", "rhs_type"]
    )

    key_hierarchies = generate_key_hierarchies(all_keymappings_df)
    key_logs_df = read_key_logs_as_df(KEY_LOGS, time_period_in_days)

    agg_df = aggregate_logs_df(key_logs_df)

    key_hierarchies = combine_mappings_with_metric(
        key_hierarchies, agg_df, active_only=(args.display == "active")
    )

    # We add nodes with stats first which might be also be parent. network respects the first add.
    # this way we can reflect heat on such keys (parent and key of action. e.g y,d)
    sorted_key_hierarchies = dict(
        sorted(
            key_hierarchies.items(),
            key=lambda item: len(item[1]["heirarchy"]),
        )
    )

    print(f"Total keys to display {len(sorted_key_hierarchies)}")
    netowrk_file = create_key_hierarchy_network(sorted_key_hierarchies)
    webbrowser.open(netowrk_file)
