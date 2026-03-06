#!/bin/bash
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=cmg276@pitt.edu
#SBATCH -M teach
#SBATCH -A hugen2072-2026s


#p4/NA12778.final.cram is the cram file

#p4/GRCh38_full_analysis_set_plus_decoy_hla.fa is the ref seq

#symbolic link was created

#extarct Chr22 alignments
module load samtools/1.22.1

samtools view -T p4/GRCh38_full_analysis_set_plus_decoy_hla.fa \
	-bS \
	-o NA12778.chr22.bam \
	-h p4/NA12778.final.cram chr22

#index

samtools index NA12778.chr22.bam

#configure and run singularity

module load singularity/4.3.2

singularity pull manta.sif docker://quay.io/biocontainers/manta:1.6.0--py27_0

singularity exec -B "$PWD" manta.sif \
configManta.py \
--referenceFasta=p4/GRCh38_full_analysis_set_plus_decoy_hla.fa \
--bam=NA12778.chr22.bam

#run Python script
singularity exec -B "$PWD" manta.sif \
python MantaWorkflow/runWorkflow.py


#examine

cd MantaWorkflow/results/variants/

#extract dups and dels
zcat diploidSV.vcf.gz | awk '{if ($5 ~ "DEL" || $5 ~ "DUP") print}' | awk -F "[\t;]" '{print $1, $2, $8, $5}' OFS="\t" | sed 's/END=//g' | awk '{if ($3 - $2 >= 1000) print}' > gt1kb.cnv.bed

#bam to cram

cd ~/2072-project4/
samtools view -h -o NA12778.chr22.cram NA12778.chr22.bam
samtools index NA12778.chr22.cram



























