#!/bin/bash

# shellcheck disable=SC1091

set -o errexit
set -o nounset
set -o pipefail
# set -o xtrace # Uncomment this line for debugging purposes

# Change max upload size for import
sed -i 's/import_file_max_size_bytes.*/import_file_max_size_bytes = "'$MAX_IMPORT_MEMORY_LIMIT'";/g' /opt/bitnami/testlink/config.inc.php

# Only execute init scripts once
if [[ ! -f "/bitnami/testlink/.user_scripts_initialized" && -d "/docker-entrypoint-init.d" ]]; then
    read -r -a init_scripts <<< "$(find "/docker-entrypoint-init.d" -type f -print0 | sort -z | xargs -0)"
    if [[ "${#init_scripts[@]}" -gt 0 ]] && [[ ! -f "/bitnami/testlink/.user_scripts_initialized" ]]; then
        mkdir -p "/bitnami/testlink"
        for init_script in "${init_scripts[@]}"; do
            for init_script_type_handler in /post-init.d/*.sh; do
                "$init_script_type_handler" "$init_script"
            done
        done
    fi

    touch "/bitnami/testlink/.user_scripts_initialized"
fi
