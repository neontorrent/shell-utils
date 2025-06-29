#!/bin/sh

DELIM="$(printf '\037')"  # ASCII Unit Separator

# Create a list with optional initial values
list_create() {
  varname=$1
  shift
  new_list=""
  for val in "$@"; do
    [ -z "$new_list" ] && new_list=$val || new_list="$new_list$DELIM$val"
  done
  eval "$varname=\$new_list"
}

# Check if a variable is set (returns 0 if set, 1 otherwise)
is_var_set() {
  varname=$1
  eval "[ \"\${$varname+x}\" ]"
}

# Append items to the list
list_append() {
  varname=$1
  shift

  if ! is_var_set "$varname"; then
    echo "Error: Variable '$varname' is not defined. Use list_create first." >&2
    return 1
  fi

  eval "current=\${$varname}"
  for val in "$@"; do
    [ -z "$current" ] && current=$val || current="$current$DELIM$val"
  done
  eval "$varname=\$current"
}

# Remove one or more items from the list
list_remove() {
  varname=$1
  shift

  if ! is_var_set "$varname"; then
    echo "Error: Variable '$varname' is not defined. Use list_create first." >&2
    return 1
  fi

  eval "current=\${$varname}"
  new_list=""

  OLD_IFS=$IFS
  IFS=$DELIM
  for item in $current; do
    skip=false
    for rem in "$@"; do
      [ "$item" = "$rem" ] && skip=true && break
    done
    [ "$skip" = false ] && [ -z "$new_list" ] && new_list=$item || [ "$skip" = false ] && new_list="$new_list$DELIM$item"
  done
  IFS=$OLD_IFS

  eval "$varname=\$new_list"
}

# Print list contents
list_print() {
  varname=$1
  
  if ! is_var_set "$varname"; then
    echo "Error: Variable '$varname' is not defined. Use list_create first." >&2
    return 1
  fi
  
  eval "current=\${$varname}"

  OLD_IFS=$IFS
  IFS=$DELIM
  for item in $current; do
    printf '%s\n' "$item"
  done
  IFS=$OLD_IFS
}
