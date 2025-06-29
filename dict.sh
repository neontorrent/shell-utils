#!/bin/sh

DELIM="$(printf '\037')"  # Unit Separator (rare character)

# Check if dictionary exists
dict_exists() {
  dictname=$1
  eval '[ "${__dict_'"$dictname"'+x}" ]'
}

# Create a dictionary with key-value pairs (multiple allowed)
dict_create() {
  dictname=$1
  shift

  if [ $(( $# % 2 )) -ne 0 ]; then
    echo "Error: dict_create requires an even number of key-value arguments." >&2
    return 1
  fi

  eval "__dict_${dictname}=''"  # initialize keys list empty

  keys=""
  while [ $# -gt 0 ]; do
    key=$1
    value=$2
    shift 2

    # Append key to keys list
    if [ -z "$keys" ]; then
      keys=$key
    else
      keys="$keys$DELIM$key"
    fi

    # Store key-value pair
    eval "__dict_${dictname}_${key}=\"\$value\""
  done

  # Save keys list
  eval "__dict_${dictname}=\"\$keys\""
}

# Set one or more key-value pairs (add new keys if needed)
dict_set() {
  dictname=$1
  shift

  if ! dict_exists "$dictname"; then
    echo "Error: Dictionary '$dictname' has not been created." >&2
    return 1
  fi

  if [ $(( $# % 2 )) -ne 0 ]; then
    echo "Error: dict_set requires even number of key-value arguments." >&2
    return 1
  fi

  eval "keys=\${__dict_${dictname}}"

  OLD_IFS=$IFS
  IFS=$DELIM
  for key in $(printf '%s\n' "$keys"); do
    :
  done  # just to set IFS for loop

  # To avoid repeatedly resetting keys variable, parse keys into a loop variable
  # We'll build keys in a shell loop below

  # We'll build a set of existing keys in keys variable
  # We'll accumulate new keys for any added keys

  # We'll parse keys into a shell variable list
  existing_keys=""
  for k in $keys; do
    if [ -z "$existing_keys" ]; then
      existing_keys=$k
    else
      existing_keys="$existing_keys$DELIM$k"
    fi
  done

  # Now process key-value pairs passed in
  while [ $# -gt 0 ]; do
    key=$1
    value=$2
    shift 2

    # Check if key exists
    found=0
    for k in $existing_keys; do
      if [ "$k" = "$key" ]; then
        found=1
        break
      fi
    done

    # If not found, append key
    if [ $found -eq 0 ]; then
      if [ -z "$existing_keys" ]; then
        existing_keys=$key
      else
        existing_keys="$existing_keys$DELIM$key"
      fi
    fi

    # Set key-value pair
    eval "__dict_${dictname}_${key}=\"\$value\""
  done
  IFS=$OLD_IFS

  # Save updated keys list
  eval "__dict_${dictname}=\"\$existing_keys\""
}

# Get the value for a key
dict_get() {
  dictname=$1
  key=$2

  if ! dict_exists "$dictname"; then
    echo "Error: Dictionary '$dictname' has not been created." >&2
    return 1
  fi

  # Retrieve value (default empty if not set)
  eval "value=\${__dict_${dictname}_${key}-}"

  printf '%s\n' "$value"
}

# Loop over all key-value pairs, calling a function with args: key value
dict_for() {
  dictname=$1
  func=$2

  if ! dict_exists "$dictname"; then
    echo "Error: Dictionary '$dictname' has not been created." >&2
    return 1
  fi

  eval "keys=\${__dict_${dictname}}"

  OLD_IFS=$IFS
  IFS=$DELIM
  for key in $keys; do
    eval "value=\${__dict_${dictname}_${key}-}"
    "$func" "$key" "$value"
  done
  IFS=$OLD_IFS
}

# Delete one or more keys from dict
dict_delete() {
  dictname=$1
  shift

  if ! dict_exists "$dictname"; then
    echo "Error: Dictionary '$dictname' has not been created." >&2
    return 1
  fi

  if [ $# -eq 0 ]; then
    echo "Error: dict_delete requires at least one key to delete." >&2
    return 1
  fi

  eval "keys=\${__dict_${dictname}}"

  OLD_IFS=$IFS
  IFS=$DELIM
  new_keys=""
  for key in $keys; do
    skip=0
    for delkey in "$@"; do
      if [ "$key" = "$delkey" ]; then
        skip=1
        break
      fi
    done
    if [ $skip -eq 0 ]; then
      if [ -z "$new_keys" ]; then
        new_keys=$key
      else
        new_keys="$new_keys$DELIM$key"
      fi
    else
      # Unset the variable for deleted key
      eval "unset __dict_${dictname}_${key} 2>/dev/null || true"
    fi
  done
  IFS=$OLD_IFS

  eval "__dict_${dictname}=\"\$new_keys\""
}


# === Example usage ===

print_kv() {
  printf "Key: '%s' Value: '%s'\n" "$1" "$2"
}

dict_create mydict "foo" "bar baz" "hello" "world"

echo "Initial dict:"
dict_for mydict print_kv

echo
echo "After setting new keys:"
dict_set mydict "new key" "new value" "foo" "updated bar baz"
dict_for mydict print_kv

echo
echo "Get specific key 'foo':"
dict_get mydict "foo"

echo
echo "After deleting 'hello' and 'new key':"
dict_delete mydict "hello" "new key"
dict_for mydict print_kv
