process SHAPEIT5_PHASECOMMON {
    tag "$meta.id"
    label 'process_medium'

    conda "bioconda::shapeit5=1.0.0"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/shapeit5:1.0.0--h0c8ee15_0':
        'quay.io/biocontainers/shapeit5:1.0.0--h0c8ee15_0'}"

    input:
        tuple val(meta) , path(input), path(input_index), val(region), path(pedigree)
        tuple val(meta2), path(reference), path(reference_index)
        tuple val(meta3), path(scaffold), path(scaffold_index)
        tuple val(meta4), path(map)

    output:
        tuple val(meta), path("*.{vcf,bcf,vcf.gz,bcf.gz}"), emit: phased_variant
        path "versions.yml"                               , emit: versions

    when:
        task.ext.when == null || task.ext.when

    script:
    def args   = task.ext.args   ?: ''

    def prefix = task.ext.prefix ?: "${meta.id}_${region.replace(":","_")}"
    def suffix = task.ext.suffix ?: "vcf.gz"

    def map_command       = map       ? "--map $map"             : ""
    def reference_command = reference ? "--reference $reference" : ""
    def scaffold_command  = scaffold  ? "--scaffold $scaffold"   : ""
    def pedigree_command  = pedigree  ? "--pedigree $pedigree"   : ""

    meta.put("SHAPEIT5_PHASECOMMON", ["reference":"", "map":"", "scaffold":""])
    meta.SHAPEIT5_PHASECOMMON.reference = reference ? meta2 :"None"
    meta.SHAPEIT5_PHASECOMMON.map       = map       ? meta3 :"None"
    meta.SHAPEIT5_PHASECOMMON.scaffold  = scaffold  ? meta4 :"None"

    """
    SHAPEIT5_phase_common \\
        $args \\
        --input $input \\
        $map_command \\
        $reference_command \\
        $scaffold_command \\
        $pedigree_command \\
        --region $region \\
        --thread $task.cpus \\
        --output ${prefix}.${suffix}

    cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            shapeit5: "\$(SHAPEIT5_phase_common | sed -nr '/Version/p' | grep -o -E '([0-9]+.){1,2}[0-9]' | head -1)"
    END_VERSIONS
    """
}
