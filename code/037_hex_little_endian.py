import argparse

def convert_hex_to_asm(input_file, output_file):
    try:
        with open(input_file, 'r', encoding='utf-8') as infile, \
             open(output_file, 'w', encoding='utf-8') as outfile:

            for line in infile:
                line = line.strip()
                if not line:
                    continue  # Skip empty lines

                hex_numbers = [token.strip() for token in line.split(',')]

                for hex_num in hex_numbers:
                    # Pad to 4 characters
                    hex_num = hex_num.zfill(4)

                    high = hex_num[:2]
                    low = hex_num[2:]

                    # Write little-endian format
                    outfile.write(f"  lda #${low}\n")
                    outfile.write("  sta soundLowByte\n")
                    outfile.write(f"  lda #${high}\n")
                    outfile.write("  sta soundHighByte\n")
                    outfile.write("  jsr playSquareWaveDelay\n")

        print(f"Assembly instructions written to: {output_file}")

    except FileNotFoundError:
        print(f"Error: File '{input_file}' not found.")
    except Exception as e:
        print(f"An error occurred: {e}")

def main():
    parser = argparse.ArgumentParser(description="Convert hex values to LDA/STA/JSR instructions in little-endian.")
    parser.add_argument('input_file', help='Path to input file')
    parser.add_argument('output_file', help='Path to output file')
    args = parser.parse_args()

    convert_hex_to_asm(args.input_file, args.output_file)

if __name__ == '__main__':
    main()
