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
) ENGINE=MyISAM DEFAULT CHARSET=latin1

LOAD DATA INFILE '/home/sadkhin2/blast' INTO TABLE BLAST fields terminated by '\t';

#Chromosomes
CHR	CREATE TABLE `CHR` (
 `query_org` varchar(255) NOT NULL,
 `query_id`  varchar(255) NOT NULL,
 `query_pac`int(11)  NOT NULL,
 `chr` varchar(255) NOT NULL,
 `start` int(11) NOT NULL,
 `stop` int(11) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1

LOAD DATA INFILE '/home/sadkhin2/allChromo' INTO TABLE CHR fields terminated by '\t';

#Annotations

ANNOTATIONS	CREATE TABLE `ANNOTATIONS` (
 `query_org` varchar(255) NOT NULL,
 `query_pac` int(11) NOT NULL,
 `locusName` varchar(255) NOT NULL,
 `transcriptName` varchar(255) NOT NULL,
 `peptideName` varchar(255) NOT NULL,
 `Pfam` varchar(255) ,
 `Panther` varchar(255),
 `KOG` varchar(255) ,
 `KEGG/EC` varchar(255) ,
 `KO` varchar(255)  ,
 `GO` varchar(255)  ,
 `Best-hit-arabi-name` varchar(255) ,
 `arabi-symbol` varchar(255) ,
 `arabi-defline` varchar(255) ,
 `Best-hit-chlamy-name` varchar(255) ,
 `chlamy-symbol` varchar(255) ,
 `chlamy-defline` varchar(255) 
) ENGINE=MyISAM DEFAULT CHARSET=latin1

LOAD DATA INFILE '/home/sadkhin2/annotation_info.TABLE.cleansed' INTO TABLE ANNOTATIONS fields terminated by '\t';

#Organisms
#Monocot, dicot, etc, common, latin, photo, version

#Chromosome_Stats
Org CHR1 Start Stop #Genes?
Org Chr2 Start stop # Genes
