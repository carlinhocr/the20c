import argparse

def convert_csv_to_hex(input_file, output_file):
    try:
        with open(input_file, 'r', encoding='utf-8') as infile, \
             open(output_file, 'w', encoding='utf-8') as outfile:

            for line in infile:
                line = line.strip()
                if not line:
                    continue  # skip empty lines

                try:
                    numbers = [int(x.strip()) for x in line.split(',')]
                    hex_values = [f'{num:04x}' for num in numbers]  # lowercase, 4-digit hex
                    outfile.write(','.join(hex_values) + '\n')
                except ValueError:
                    print(f"Warning: Skipping line due to invalid integer values: {line}")

        print(f"Hex values written to: {output_file}")

    except FileNotFoundError:
        print(f"Error: File '{input_file}' not found.")
    except Exception as e:
        print(f"An error occurred: {e}")

def main():
    parser = argparse.ArgumentParser(description='Convert CSV of integers to 4-digit lowercase hex (no 0x).')
    parser.add_argument('input_file', help='Path to input CSV file')
    parser.add_argument('output_file', help='Path to output file')
    args = parser.parse_args()

    convert_csv_to_hex(args.input_file, args.output_file)

if __name__ == '__main__':
    main()
