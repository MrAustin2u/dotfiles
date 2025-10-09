# set the path for postgres client utils on mac
if [[ "$(uname)" == "Darwin" ]]; then
  export PATH="/Applications/Postgres.app/Contents/Versions/16/bin:$PATH"
fi
