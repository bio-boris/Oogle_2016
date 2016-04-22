import re
from collections import defaultdict
import os
import sys
import phpserialize


def get_org_chromos(chr_file):
    org_chromos = defaultdict(set)
    with open(chr_file) as chr_handle:
        field_names = chr_handle.readline().strip().split('\t')
        field_idx = {field:field_names.index(field) for field in field_names}
        for line in chr_handle:
            values = line.strip().split('\t')
            org, chromo = (values[field_idx['query_org']], values[field_idx['chr']])
            org_chromos[org].add(chromo)
    return org_chromos

def split_chr_name(chr_name):
    """ Attempts to split word portion of chromosome name from numeric portion.
        Will parse 4 types of chromosome naming conventions:
            (1) full numeric
            (2) full alphabetic
            (3) alphanumeric/punctuation followed by numeric
            (4) alphanumeric/punctuation followed by numeric followed by alphanumeric/punctuation
        These patterns cover all naming conventions used by sequencing projects
        deposited in Phytozome as of 4/22/16. """
    
    match = re.search('(.*?)([\d\.]+)([^\d\.]*)$', chr_name)
    if match:
        return [grp for grp in match.groups() if grp]
    return [chr_name]

def get_words(chr_names):
    return set(word for chromo in chr_names for word in split_chr_name(chromo) if not word.isdigit())

def get_nonprefixes(chr_names):
    chromosome_nonprefixes = set()
    for chromo in chr_names:
        match = re.search('[^A-Za-z_]+([A-Za-z_]+)', chromo)
        if match:
                    chromosome_nonprefixes.update(match.groups())
    return chromosome_nonprefixes

def get_non_standard_numbers(chr_names):
    chromosome_numbers = set()
    for chromo in chr_names:
        match = re.search('(\d+)\.?(\d*)', chromo)
        if match:
            if not match.groups()[1]:
                numstr = match.groups()[0]
                if str(int(numstr)) != numstr:
                    chromosome_numbers.add(numstr)
            elif match.groups()[1]:
                numstr = match.groups()[0]+'.'+match.groups()[1]
                if str(float(numstr)) != numstr:
                    chromosome_numbers.add(numstr)
    return chromosome_numbers

def compile_organism_chromos(chr_file, org_chromo_file):
    org_chromos = get_org_chromos(chr_file)
    with open(org_chromo_file, 'w') as org_chromo_handle:
        org_chromo_handle.write('\n'.join(org+'\t'+chromo for org in org_chromos for chromo in org_chromos[org]))

def retrieve_organism_chromos(org_chromo_file):
    org_chromos = defaultdict(set)
    with open(org_chromo_file) as org_chromo_handle:
        for line in org_chromo_handle:
            values = line.strip().split('\t')
            org_chromos[values[0]].add(values[1])
    return org_chromos

def get_edits_d1(word):
    """ Function for retrieving all possible edits within Damerau-Levenshtein
        distance of 1 derived from tutorial by Peter Norvig"""
    alphabet = 'abcdefghijklmnopqrstuvwxyz'
    splits = [(word[:i],word[i:]) for i in xrange(len(word) + 1)]
    deletes = [a + b[1:] for (a,b) in splits if b]
    transposes = [a + b[1] + b[0] + b[2:] for (a,b) in splits if len(b) > 1]
    replaces = [a + c + b[1:] for (a,b) in splits for c in alphabet if b]
    inserts = [a + c + b for (a,b) in splits for c in alphabet]
    return set(deletes + transposes + replaces + inserts)

def get_edits_d2(word):
    edits_d2 = set()
    for edit in get_edits_d1(word):
        edits_d2.update(get_edits_d1(edit))
    return edits_d2

def get_present(words, dictionary):
    standardized_dictionary = defaultdict(set)
    for word in dictionary:
        standardized_dictionary[''.join(re.findall('\w+', word)).lower()].add(word)
    words_present = set()
    for word in words:
        std_word = ''.join(re.findall('\w+', word)).lower()
        if std_word in standardized_dictionary:
            words_present.update(standardized_dictionary[std_word])
    return words_present

def get_correct_words(word, dictionary):
    return get_present([word], dictionary) or get_present(get_edits_d1(word), dictionary) \
        or get_present(get_edits_d2(word), dictionary) or None

def get_corrections(chr_name, chromos):
    """ Attempts to find potential correct chromosome names from input string """

    if chr_name in chromos:
        print 'FOUND'
        return set([chr_name])

    split_name = split_chr_name(chr_name)

    if len(split_name) == 1:
        one_grp_names = [name for name in chromos if len(split_chr_name(name)) == 1]
        try:
            print 'TRYING INT'
            norm_name = str(int(split_name[0]))
            one_grp_numerics = defaultdict(set)
            for name in one_grp_names:
                    if name.isdigit():
                        one_grp_numerics[str(int(name))].add(name)
            if norm_name in one_grp_numerics:
                return one_grp_numerics[norm_name]
            else:
                print 'TRYING PREFIXED INTS'
                numeric_map = defaultdict(set)
                for name in chromos:
                    name_split = split_chr_name(name)
                    if len(name_split) > 1:
                        numeric_map[str(int(name_split[1]))].add(name)
                if norm_name in numeric_map:
                    return numeric_map[norm_name]
        except ValueError:
            print 'VALUEERROR'
            return get_correct_words(split_name[0],
                [name for name in one_grp_names if not name.isdigit()])
    if len(split_name) > 1:
        same_grp_chromos = [split_chr_name(name) for name in chromos 
                            if len(split_chr_name(name)) == len(split_name)]
        same_grp_chromos_std = {''.join(chromo[0]+str(int(chromo[1]))+''.join(chromo[2:])):''.join(chromo)
                                for chromo in same_grp_chromos}

        prefix = split_name[0]
        numeric = split_name[1]
        correct_prefixes = get_correct_words(prefix, 
                                             set(chromo[0] for chromo in same_grp_chromos))
        if not correct_prefixes:
            return None
        potential_names = set()
        if len(split_name) == 2:
            print 'ENTERING 2 GROUP'
            for prefix in correct_prefixes:
                print prefix
                chromo_std = prefix+str(int(numeric))
                print chromo_std
                if chromo_std in same_grp_chromos_std:
                    potential_names.add(same_grp_chromos_std[chromo_std])
        elif len(split_name) == 3:
            print 'ENTERING 3 GROUP'
            suffix = split_name[2]
            correct_suffixes = get_correct_words(suffix, 
                                             set(chromo[2] for chromo in same_grp_chromos))
            if not correct_suffixes:
                return None
            for prefix in correct_prefixes:
                for suffix in correct_suffixes:
                    chromo_std = prefix+str(int(numeric))+suffix
                    if chromo_std in same_grp_chromos_std:
                        potential_names.add(same_grp_chromos_std[chromo_std])
        return potential_names
    print 'NOTHING RETURNED YET'

def main():
    chr_file = 'CHR_DUMP'
    org_chromo_file = 'organism_chromosomes.tsv'
    if not os.path.exists(org_chromo_file):
        compile_organism_chromos(chr_file, org_chromo_file)

    org_chromos = retrieve_organism_chromos(org_chromo_file)

    php_dump = sys.argv[1]
    input_dict = phpserialize.loads(php_dump)
    output_intervals = []
    organism = input_dict[max(input_dict.keys())].split('=')[1]
    del input_dict[max(input_dict.keys())]
    for interval in input_dict:
        match = re.search('(.+)[-:_](\d+-\d+)', input_dict[interval])
        if match:
            fields = match.groups()
            print fields
            chromo, region = fields[:2]
            try:
                region_min, region_max = map(int, region.split('-'))
                if region_min >= region_max:
                    output_intervals.append('INTERVAL_ERROR')
                    continue
            except ValueError:
                print 'valueerr'
                output_intervals.append('INTERVAL_ERROR')
                continue
            corrections = get_corrections(chromo, org_chromos[organism])
            if corrections:
                output_intervals.append('|'.join([chromo+':'+region for chromo in corrections]))
            else:
                print 'ERRORFOUND'
                output_intervals.append('ERROR')
        else:
            output_intervals.append('INTERVAL_ERROR')
        print input_dict[interval], output_intervals, '\n'

    print output_intervals
    sys.stdout.write(phpserialize.dumps(output_intervals))

    # find all non-standard formats
    # for org in org_chromos:
    #     print org, '\t', get_nonprefixes(org_chromos[org]), '\n'
    #     raw_input()

    # [(org, chromo) for org in org_chromos for chromo in org_chromos[org] if not re.search('\d', chromo)]

if __name__=='__main__':
    main()
