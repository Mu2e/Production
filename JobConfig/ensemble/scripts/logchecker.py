import csv
import os

# Define the directory where your log files are located
log_directory = "logs"  
output_file_name = "extracted_data.txt"
output_csv_file_name = "output_data.csv"

start_marker = "Dataset        Counts"
end_marker = "Total"

extracting = False  # A flag to indicate whether we are currently extracting lines
extracted_lines = []

all_extracted_lines = [] # To store all extracted lines from all files

try:
    # Iterate through all files in the specified directory.
    for filename in os.listdir(log_directory):
        if filename.endswith(".log"):  # Process only files ending with .txt (adjust as needed).
            file_path = os.path.join(log_directory, filename) # Construct the full file path

            extracting = False
            extracted_lines_from_current_file = []

            with open(file_path, 'r') as input_file:
                for line in input_file:
                    if start_marker in line:
                        extracting = True

                    if extracting:
                        extracted_lines_from_current_file.append(line.strip())

                    if end_marker in line and extracting:
                        extracting = False
                        # If you want to *exclude* the end_marker, 
                        # you would need to adjust the logic as previously discussed.

            if extracted_lines_from_current_file:
                # Add a separator to indicate the file where data was extracted from
                #all_extracted_lines.append(f"\n--- Extracted from: {filename} ---\n")
                all_extracted_lines.extend(extracted_lines_from_current_file)
      
except FileNotFoundError:
    print(f"Error: The directory '{log_directory}' was not found, or there are no '.txt' files in it.")
except Exception as e:
    print(f"An unexpected error occurred: {e}")

# Write all extracted lines to a single output file.
if all_extracted_lines:
    with open(output_file_name, "a") as output_file:
        for line in all_extracted_lines:
            output_file.write(line + "\n")
        output_file.write("EOF")
    print(f"Extracted lines from files in '{log_directory}' have been combined and added to '{output_file_name}'.")
else:
    print(f"No blocks of text between '{start_marker}' and '{end_marker}' were found in any files in '{log_directory}'.")
# Now tranfer what we need to the csv
# Manually define the header since it's a bit tricky to parse automatically


header = ["Dataset", "Counts", "fraction_sampled", "fraction_expected", "weight"]

data_lines = []
try:
    with open(output_file_name, 'r') as input_file:
        lines = input_file.readlines() # Read all lines into a list
        
        # Find the start and end of the table data
        # Skip header and separator line
        start_index = 2 
        # Find the index of the "Total" line to determine the end of the data rows
        end_index = -1
        for i, line in enumerate(lines):
            if "EOF" in line:
                end_index = i
                break
        
        # Extract only the data lines from the table
        if end_index != -1:
            data_lines = [line.strip() for line in lines[start_index:end_index] if line.strip()]
        else:
            print("Warning: 'Total' line not found, processing all lines after header.")
            data_lines = [line.strip() for line in lines[start_index:] if line.strip()]

except FileNotFoundError:
    print(f"Error: The file '{output_file_name}' was not found.")
    exit() # Exit if the input file isn't found

with open(output_csv_file_name, 'w', newline='') as csvfile:
    csv_writer = csv.writer(csvfile)

    # Write the header row
    csv_writer.writerow(header)
    # Write the data rows and aggregate counts per dataset
    totals = {}

    for line in data_lines:
        # Split the line by whitespace
        row_data = line.split()
        # Accept lines that have at least dataset and counts
        if len(row_data) >= 2 and row_data[0] != 'Dataset':
          dataset = row_data[0]
          counts = row_data[1]
          fraction_sampled = row_data[2] if len(row_data) > 2 else ''
          fraction_expected = row_data[4] if len(row_data) > 4 else ''
          weight = row_data[5] if len(row_data) > 5 else ''

          cleaned_row = [dataset, counts, fraction_sampled, fraction_expected, weight]
          csv_writer.writerow(cleaned_row)

          # Aggregate counts for dataset totals (handle commas and floats)
          count_str = counts
          try:
              count_val = int(count_str.replace(',',''))
          except ValueError:
              try:
                  count_val = int(float(count_str.replace(',','')))
              except Exception:
                  count_val = 0

          totals[dataset] = totals.get(dataset, 0) + count_val

# Print dataset totals summary
if totals:
    print("Total Counts per Dataset:")
    for ds, tot in totals.items():
        print(f"{ds}: {tot}")

print(f"Data has been written to {output_csv_file_name}")

