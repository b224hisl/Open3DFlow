import sys
import os

def tsv_loc(x,y):
    result_dir = os.getenv('RESULTS_DIR')
    print (result_dir)
    output_file = os.path.join(result_dir,'tsv_resize.txt')
    with open(output_file, 'a') as file:
        file.write(f"{x}, {y}, 30.24, 5.5\n")


if __name__ == "__main__":
    x = float(sys.argv[1])/2000
    y = float(sys.argv[2])/2000
    tsv_loc(x, y)