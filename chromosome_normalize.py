import sys
import re
import glob


def normalize_chromo_header(chromo):
    hit = re.match('([Cc]hr_?)(\d+)', chromo)
    if hit:
        return 'Chr'+hit.groups()[1]
    hit = re.match('([Cc]hromosome_?)(\d+)', chromo)
    if hit:
        return 'Chr'+hit.groups()[1]
    hit = re.match('^(\d+)$', chromo)
    if hit:
        number = int(hit.groups()[0])
        if number <= 200: return 'Chr'+str(number)
    return chromo

def drop_leading_zeroes(chromo):
    hit = re.match('(Chr)(0\d)(.*)', chromo)
    if hit:
        return hit.groups()[0]+str(int(hit.groups()[1]))+hit.groups()[2]
    else:
        return chromo

def gt200(chromo):
    try:
        return int(chromo) > 200
    except ValueError:
        return False

def main():
    chr_files = glob.glob('/gpfs/gpfs_scratch01/scratch/users/sadkhin2/phytozome_11/*/annotation/*.CHR')
    for f in chr_files:
        with open(f) as chr_file:
            with open(f+'.NORMALIZED', 'w') as outfile:
                for line in chr_file:
                    values = line.split()
                    chromo = values[3]
                    chromo = drop_leading_zeroes(normalize_chromo_header(chromo))
                    if not gt200(chromo) and re.match('Chr\d+', chromo):
                        values[3] = chromo
                        norm_line = '\t'.join(values)
                        outfile.write(norm_line+'\n')

if __name__=='__main__':
    main()