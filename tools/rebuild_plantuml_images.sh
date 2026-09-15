#!/bin/sh

set -e

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)

cd "$SCRIPT_DIR" || exit 1

if [ ! -f "plantuml.jar" ]; then
    echo "Download plantuml.jar.."
    LATEST_RELEASE_JSON=$(curl -sL https://api.github.com/repos/plantuml/plantuml/releases/latest)
    JAR_URL=$(echo "$LATEST_RELEASE_JSON" | \
        grep -o '"browser_download_url": *"[^"]*\.jar"' | \
        grep -v "javadoc" | \
        grep -v "sources" | \
        head -1 | \
        sed 's/"browser_download_url": *"//;s/"//')
    echo "$JAR_URL"
    wget -O "plantuml.jar" "$JAR_URL"
fi

if [ ! -f "plantuml.jar" ]; then
    echo "Error: plantuml.jar don't exists"
    exit 1
fi

for task_dir in ../tasks/task*; do
    if [ -d "$task_dir" ]; then
        find "$task_dir" -maxdepth 1 -type f -name "*.puml" | while read puml_file; do
            printf "%s" "$puml_file"
            png_file=$(echo "$puml_file" | sed 's/\.puml$/.png/')
            cat "$puml_file" | java -Djava.awt.headless=true -jar plantuml.jar -pipe > "$png_file"
            if [ $? -eq 0 ]; then
                echo "  ✓ -> $png_file"
            else
                echo "  ✗"
            fi
        done
    fi
done

echo "Done!"
