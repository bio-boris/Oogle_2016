#Blast
CREATE TABLE `BLAST` (
 `query_org` varchar(255) NOT NULL,
 `subject_org` varchar(255) NOT NULL,
 `query_id` varchar(255) NOT NULL,
 `subject_id` varchar(255) NOT NULL,
 `percent_id` int(11) NOT NULL,
 `alignment_length` int(11) NOT NULL,
 `expect` varchar(255) NOT NULL,
 `bitscore` int(11) NOT NULL,
 `rank` int(11) NOT NULL,
 `query_pac` int(11) NOT NULL,
 `subject_pac` int(11) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin

#Chromosomes
CHR	CREATE TABLE `CHR` (
 `query_org` varchar(255) NOT NULL,
 `query_pac` int(11) NOT NULL,
 `query_id` varchar(255) NOT NULL,
 `chr` varchar(255) NOT NULL,
 `start` int(11) NOT NULL,
 `stop` int(11) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1

#Annotations

ANNOTATIONS	CREATE TABLE `ANNOTATIONS` (
 `query_org` varchar(255) NOT NULL,
 `query_pac` int(11) NOT NULL,
 `locusName` varchar(255) NOT NULL,
 `transcriptName` varchar(255) NOT NULL,
 `peptideName` varchar(255) NOT NULL,
 `Pfam` varchar(255) NOT NULL,
 `Panther` varchar(255) NOT NULL,
 `KOG` varchar(255) NOT NULL,
 `KEGG/EC` varchar(255) NOT NULL,
 `KO` varchar(255) NOT NULL,
 `GO` varchar(255) NOT NULL,
 `Best-hit-arabi-name` varchar(255) NOT NULL,
 `arabi-symbol` varchar(255) NOT NULL,
 `arabi-defline` varchar(255) NOT NULL,
 `Best-hit-chlamy-name` varchar(255) NOT NULL,
 `chlamy-symbol` varchar(255) NOT NULL,
 `chlamy-defline` varchar(255) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1


#Organisms
#Monocot, dicot, etc, common, latin, photo, version

#Chromosome_Stats
Org CHR1 Start Stop #Genes?
Org Chr2 Start stop # Genes
