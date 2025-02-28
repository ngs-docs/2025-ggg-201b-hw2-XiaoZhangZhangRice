rule all:
    input:
        "SRR2584857_quast.10223199", # use 3/5 of reads - coverage: 2.3
        "SRR2584857_annot.10223199",
        "SRR2584857_quast.13630932", # use 4/5 of reads - coverage:3
        "SRR2584857_annot.13630932",
        "SRR2584857_quast.17038664", # use all of reads - coverage:3.8
        "SRR2584857_annot.17038664",


rule subset_reads:
    input:
        "{sample}.fastq.gz",
    output:
        "{sample}.{subset,\d+}.fastq.gz"
    shell: """
        gunzip -c {input} | head -{wildcards.subset} | gzip -9c > {output} || true
    """

rule annotate:
    input:
        "SRR2584857-assembly.{subset}.fa"
    output:
        directory("SRR2584857_annot.{subset}")
    shell: """
       prokka --prefix {output} {input}                                       
    """

rule assemble:
    input:
        r1 = "SRR2584857_1.{subset}.fastq.gz",
        r2 = "SRR2584857_2.{subset}.fastq.gz"
    output:
        dir = directory("SRR2584857_assembly.{subset}"),
        assembly = "SRR2584857-assembly.{subset}.fa"
    shell: """
       megahit -1 {input.r1} -2 {input.r2} -f -m 5e9 -t 4 -o {output.dir}     
       cp {output.dir}/final.contigs.fa {output.assembly}                     
    """

rule quast:
    input:
        "SRR2584857-assembly.{subset}.fa"
    output:
        directory("SRR2584857_quast.{subset}")
    shell: """                                                                
       quast {input} -o {output}                                              
    """
