// ─────────────────────────────
// 🧬 check_env.nf — Nextflow DSL2 workflow module
// ─────────────────────────────

nextflow.enable.dsl=2

workflow check_env {

    def target_env = params.conda_env ?: 'port_env'

    println "--------------------------------"
    println "User has specified -profile conda"
    println "--------------------------------"

    println "   "
    println "🔧 Checking Conda environment status for '${target_env}'..."
    println "   "

    // STEP 1: Check or activate Conda environment
    def conda_base_proc = ["bash", "-c", "conda info --base"].execute()
    def conda_base = conda_base_proc.text.trim()

    if (!conda_base || !new File("${conda_base}/etc/profile.d/conda.sh").exists()) {
        println "❌ Conda base not found. Please ensure Conda is installed."
        System.exit(1)
    }

    // Check if environment exists
    def check_env_proc = ["bash", "-c", "conda env list | awk '{print \$1}' | grep -w ${target_env}"].execute()
    def env_exists = check_env_proc.text.trim()

    if (!env_exists) {
        println "   "
        println "❌ Conda environment '${target_env}' not found."
        println "   "
        println "   "
        println "   Create it using: conda env create -f envs/environment.yml -y"
        System.exit(1)
    }

    // Check active environment
    def env_name = System.getenv('CONDA_DEFAULT_ENV')

    if (!env_name) {
        println "❌ Conda environment is not activated!"
        println "---------------------------------------------------------------------"
        println "   Please activate the '${target_env}' environment before running:"
        println "   conda activate ${target_env}"
        println "---------------------------------------------------------------------"
        System.exit(1)
    }

    if (env_name != target_env) {
        println "❌ Wrong Conda environment detected!"
        println "---------------------------------------------------------------------"
        println "   Currently active: '${env_name}'"
        println "   Required: '${target_env}'"
        println "---------------------------------------------------------------------"
        println ""
        println "---------------------------------------------------------------------"
        println "👉 Please activate the correct environment before starting the pipeline:"
        println "   conda activate ${target_env}"
        println "---------------------------------------------------------------------"
        System.exit(1)
    }
    println "---------------------------------------------------------------------"
    println "✅ Conda environment '${target_env}' is active."
    println "---------------------------------------------------------------------"

    // STEP 2: Verify essential tools inside environment
    println "   "
    println "🔍 Checking essential tools inside '${target_env}'..."
    def essential_tools = ["autocycler", "mob_recon", "amrfinder", "plasmidfinder.py", "plassembler"]
    def missing = []
    essential_tools.each { tool ->
        def check = ["bash", "-c", "conda run -n ${target_env} which ${tool} >/dev/null 2>&1"].execute()
        check.waitFor()
        if (check.exitValue() != 0) missing << tool
    }

    if (missing) {
        println "------------------------------------------------------------------------------"
        println "❌ The following tools are missing in '${target_env}': ${missing.join(', ')}"
        println "   Please reinstall them using: conda install -n ${target_env} <tool>"
        println "------------------------------------------------------------------------------"
        System.exit(1)
    } else {
        println "--------------------------------------------------------"
        println "✅ All required tools are available in '${target_env}'."
        println "--------------------------------------------------------"
    }

    // STEP 3: Check databases
    println "------------------------"
    println "🔍 Checking databases..."
    println "------------------------"

    def conda_prefix_proc = ["bash", "-c", "conda run -n ${target_env} python -c 'import sys; print(sys.prefix)'"].execute()
    def conda_prefix = conda_prefix_proc.text.trim()

    // MOB-suite
    def mob_db_path = "${conda_prefix}/lib/python3.11/site-packages/mob_suite/databases"
    if (new File(mob_db_path).exists()) {
        println "//   "
        println "   ✅ MOB-suite database found at: ${mob_db_path}"
        println "//   "
    } else {
        println "⚠️ MOB-suite database missing. Please reinstall mobsuite."
    }

    // PlasmidFinder
    def plasmid_db_path = "${conda_prefix}/share/plasmidfinder-2.1.6/database"
    if (new File(plasmid_db_path).exists()) {
        println "//   "
        println "   ✅ PlasmidFinder database found at: ${plasmid_db_path}"
        println "//   "
    } else {
        println "⚠️ PlasmidFinder database not found. Attempting to download..."
        def dl_cmd = "bash -c 'cd ${conda_prefix}/share/plasmidfinder-2.1.6 && ./download-db.sh'"
        ["bash", "-c", "conda run -n ${target_env} ${dl_cmd}"].execute().waitFor()
        if (new File(plasmid_db_path).exists()) {
            println "   "
            println "✅ PlasmidFinder database downloaded successfully."
        } else {
            println "   "
            println "❌ Failed to download PlasmidFinder database."
        }
    }

    // ─────────────────────────────
    // 💊 AMRFinderPlus Database Check (Path-based)
    // ─────────────────────────────
    println "   "
    println "🔍 Checking AMRFinderPlus database..."
    println "   "

    def amr_db_base = "${conda_base}/envs/${target_env}/share/amrfinderplus/data"
    def amr_db_dir = new File(amr_db_base)

    if (amr_db_dir.exists() && amr_db_dir.isDirectory()) {
        // Find subdirectories (database versions)
        def subdirs = amr_db_dir.listFiles().findAll { it.isDirectory() }
        if (subdirs && subdirs.size() > 0) {
            // Sort and pick the latest (by date name)
            def latest_db = subdirs.sort { a, b -> b.name <=> a.name }[0]
            println "//  "
            println "   ✅ AMRFinderPlus database found: ${latest_db.name}"
            println "   📁 Path: ${latest_db.absolutePath}"
            println "//  "
        } else {
            println "   "
            println "⚠️  AMRFinderPlus database folder found but empty. Downloading latest version..."
            def amr_update = ["bash", "-c", "conda run -n ${target_env} amrfinder -u"].execute()
            amr_update.waitFor()
            if (amr_update.exitValue() == 0) {
                println "    "
                println "✅ AMRFinderPlus database downloaded successfully."
            } else {
                println "❌ Failed to download AMRFinderPlus database."
            }
        }
    } else {
        println "⚠️  AMRFinderPlus database directory not found. Downloading latest version..."
        def amr_update = ["bash", "-c", "conda run -n ${target_env} amrfinder -u"].execute()
        amr_update.waitFor()
        if (amr_update.exitValue() == 0) {
            println "✅ AMRFinderPlus database downloaded successfully."
        } else {
            println "❌ Failed to download AMRFinderPlus database."
        }
    }

    // Plassembler
    def plassembler_db_path = "${conda_prefix}/plassembler_db"
    if (new File(plassembler_db_path).exists()) {
        println "//   "
        println "   ✅ Plassembler database found at: ${plassembler_db_path}"
        println "//   "
    } else {
        println "⚠️ Plassembler database not found. Downloading..."
        def plassembler_cmd = "conda run -n ${target_env} plassembler download -d ${plassembler_db_path}"
        def plassembler_proc = ["bash", "-c", plassembler_cmd].execute()
        plassembler_proc.waitFor()
        if (new File(plassembler_db_path).exists()) {
            println "   "
            println "✅ Plassembler database downloaded successfully."
            println "   "
        } else {
            println "❌ Failed to download Plassembler database."
        }
    }
    println "//////========================================================================////"
    println "/////   🎉 Environment '${target_env}' validated and all databases checked.   ////"
    println "////==========================================================================////"
    println "   "
}
