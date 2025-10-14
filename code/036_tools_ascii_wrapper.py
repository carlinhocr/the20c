import argparse

def quote_lines(input_file, output_file):
    try:
        with open(input_file, 'r', encoding='utf-8') as infile, \
             open(output_file, 'w', encoding='utf-8') as outfile:
            for line in infile:
                line = line.rstrip('\n')
                quoted_line = f'  .ascii "{line}"\n'
                outfile.write(quoted_line)
        print(f"Quoted lines written to: {output_file}")
    except FileNotFoundError:
        print(f"Error: File '{input_file}' not found.")
    except Exception as e:
        print(f"An error occurred: {e}")

def main():
    parser = argparse.ArgumentParser(description='Wrap each line of a file in quotes and save to another file.')
    parser.add_argument('input_file', help='Path to the input file')
    parser.add_argument('output_file', help='Path to the output file')
    args = parser.parse_args()

    quote_lines(args.input_file, args.output_file)

if __name__ == '__main__':
    main()