info() {
  #echo "`date +\"%M:%S\"`  $*"
  echo "       $*"
}

indent() {
  while read LINE; do
    echo "       $LINE" || true
  done
}

head() {
  echo ""
  echo "-----> $*"
}

file_contents() {
  if test -f $1; then
    echo "$(cat $1)"
  else
    echo ""
  fi
}

load_config() {
  info "Loading config..."

  local custom_config_file="${build_dir}/phoenix_static_buildpack.config"

  # Source for default versions file from buildpack first
  source "${build_pack_dir}/phoenix_static_buildpack.config"

  if [ -f $custom_config_file ]; then
    source $custom_config_file
  else
    info "WARNING: phoenix_static_buildpack.config wasn't found in the app"
    info "Using default config from Phoenix static buildpack"
  fi

  phoenix_dir=$build_dir/$phoenix_relative_path

  info "Setting assets directory"
  # I've got a custom janky configuration
  assets_path=.
  phoenix_ex=phx

  assets_dir=$phoenix_dir/$assets_path
  info "Will use phoenix configuration:"
  info "* assets path ${assets_path}"
  info "* mix tasks namespace ${phoenix_ex}"

  info "Will use the following versions:"
  info "* Node ${node_version}"
}

export_config_vars() {
  whitelist_regex=${2:-''}
  blacklist_regex=${3:-'^(PATH|GIT_DIR|CPATH|CPPATH|LD_PRELOAD|LIBRARY_PATH)$'}
  if [ -d "$env_dir" ]; then
    info "Will export the following config vars:"
    for e in $(ls $env_dir); do
      echo "$e" | grep -E "$whitelist_regex" | grep -vE "$blacklist_regex" &&
      export "$e=$(cat $env_dir/$e)"
      :
    done
  fi
}

export_mix_env() {
  if [ -z "${MIX_ENV}" ]; then
    if [ -d $env_dir ] && [ -f $env_dir/MIX_ENV ]; then
      export MIX_ENV=$(cat $env_dir/MIX_ENV)
    else
      export MIX_ENV=prod
    fi
  fi

  info "* MIX_ENV=${MIX_ENV}"
}
