for input_format in $(pandoc --list-input-formats && pandoc --list-output-formats); do
    for ext in $(pandoc --list-extensions=$input_format); do
        echo $input_format $ext
    done
done | sort | uniq
