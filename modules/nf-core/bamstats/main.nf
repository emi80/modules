process BAMSTATS {
    tag "$meta.id"
    label 'process_medium'

    conda "bioconda:bamstats=0.3.5"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/bamstats:0.3.5--he881be0_0':
        'quay.io/biocontainers/bamstats:0.3.5--he881be0_0' }"

    input:
    tuple val(meta), path(bam)
    path(annotation)

    output:
    tuple val(meta), path("*_stats.json"), emit: stats
    path "versions.yml"                  , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    def logLevel = task.ext.logLevel ?: "debug"
    def annotationArgs = annotation ? "-a ${annotation}" : ""
    """
    bamstats $args \\
        -c ${task.cpus} \\
        -i ${bam} \\
        ${annotationArgs} \\
        -o ${prefix}_stats.json \\
        --loglevel ${logLevel} \\
        -u

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        bamstats: \$(echo \$(bamstats --version | awk -F": " '\$0~/version/{print \$2}'))
    END_VERSIONS
    """
}
