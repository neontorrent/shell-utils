#!/bin/sh

dict_set_value() {
    dict="$1"
    key="$2"
    value="$3"
    internal_prefix="_dict_${dict}_"
    eval "$internal_prefix$key=\"\$value\""
}

dict_get_value() {
    dict="$1"
    key="$2"
    internal_prefix="_dict_${dict}_"
    eval echo "\$$internal_prefix$key"
}

dict_for() {
    dict="$1"
    func="$2"
    internal_prefix="_dict_${dict}_"

    for var in $(set | grep "^${internal_prefix}" | cut -d= -f1); do
        key="${var#$internal_prefix}"
        value=$(eval echo "\$$var")
        "$func" "$key" "$value"
    done
}

# Example
foo="foo"
dict_set_value "$foo" "a" 1
dict_set_value "$foo" "b" 2

dict_get_value "$foo" "a" 
# print 1

process_foo() {
  key="$1"
  value="$2"
  echo "There is a key $key and value $value"
}
dict_for "$foo" process_foo
# print:
# There is a key a and value 1
# There is a key b and value 2
