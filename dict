#!/bin/sh

dict_set_value() {
    dict=$1
    key=$2
    value=$3
    internal_prefix="_dict_${dict}_"
    eval "$internal_prefix$key=\"\$value\""
}

dict_get_value() {
    dict=$1
    key=$2
    internal_prefix="_dict_${dict}_"
    eval echo "\$$internal_prefix$key"
}

dict_for() {
    dict=$1
    func="$2"
    internal_prefix="_dict_${dict}_"

    for var in $(set | grep "^${internal_prefix}" | cut -d= -f1); do
        key="${var#$internal_prefix}"
        value=$(eval echo "\$$var")
        "$func" "$key" "$value"
    done
}
