# Support Bash or Zsh

array_remove() {
    if [ "$#" -lt 2 ]; then
        echo '
Usage: 
    array_remove array_name [element_to_remove] *
        
Example:
    arr=("one 1" "two 2")
    array_remove arr "one 1"
    declare -p arr
    # arr will now only contain "two 2"
'

        return 1
    fi

    local array_name="$1"
    shift

    # Copy the array into a local variable
    eval "local -a original_array=(\"\${${array_name}[@]}\")"

    local -a result=()
    local keep
    local elem del

    for elem in "${original_array[@]}"; do
        keep=1
        for del in "$@"; do
            if [ "$elem" = "$del" ]; then
                keep=0
                break
            fi
        done
        [ "$keep" -eq 1 ] && result+=("$elem")
    done

    # Assign result back to the original array
    eval "$array_name=(\"\${result[@]}\")"
}
