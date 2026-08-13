# nvm: 起動時に本体を読まず、default node の bin だけ PATH に乗せる
#   フル nvm.sh は 300–400ms かかる。`nvm` / `npm` 切替が必要なときだけ遅延ロード。
#   従来どおり即ロードしたい: export NVM_EAGER=1  または  touch ~/.nvm_eager

if [ ! -d "${NVM_DIR:-$HOME/.nvm}" ] && [ ! -d "$HOME/.nvm" ]; then
  return 0 2>/dev/null || true
fi

export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"

_nvm_load() {
  # shellcheck disable=SC1091
  [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
  # shellcheck disable=SC1091
  [ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"
  unset -f _nvm_load nvm 2>/dev/null || true
}

if [ -n "${NVM_EAGER:-}" ] || [ -f "$HOME/.nvm_eager" ]; then
  _nvm_load
else
  # 既定バージョンの bin だけ先に通す（npm/node はそのまま使える）
  if [ -z "${NVM_BIN:-}" ]; then
    _nvm_default=
    if [ -s "$NVM_DIR/alias/default" ]; then
      _nvm_ver=$(cat "$NVM_DIR/alias/default" 2>/dev/null)
      # alias が "lts/*" などの場合は versions を走査
      if [ -d "$NVM_DIR/versions/node/$_nvm_ver" ]; then
        _nvm_default="$NVM_DIR/versions/node/$_nvm_ver"
      fi
    fi
    if [ -z "$_nvm_default" ]; then
      # 最新 v* を採用（ソートはバージョン順）
      _nvm_default=$(ls -1d "$NVM_DIR/versions/node"/v* 2>/dev/null | sort -V | tail -1)
    fi
    if [ -n "$_nvm_default" ] && [ -d "$_nvm_default/bin" ]; then
      prepend_path "$_nvm_default/bin"
    fi
    unset _nvm_default _nvm_ver
  fi

  # nvm コマンドが呼ばれたときだけ本体を読む
  nvm() {
    _nvm_load
    nvm "$@"
  }
fi
