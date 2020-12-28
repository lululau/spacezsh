#!/usr/bin/env zsh

typeset -A SPACEZSH_ALIAS_MAPPINGS=(
    # ls
    'll' 'l\n'
    'lL' 'ls\n'
    'ls' 'l -Sh\n'
    'l1' 'ls -1\n'
    'lr' 'l -tr\n'
    'lR' 'la -tr\n'
    'la' 'la\n'
    'lA' 'lA\n'
    $'\eL' 'ls\n'

    # ssh-dialog
    $'\eS' 'ss\n'

    # git
    'gs' 'git status\n'
    'gS' 'git multi-status\n'
    'gB' 'git multi-branch\n'
    'gd' 'git diff\n'
    'gl' 'git log\n'
    'gp' 'git log -p\n'
    'g-' 'git checkout -\n'
    'gg' 'magit\n'
    $'\x18@sg' 'magit\n'
    'gr' 'git remote -vvv\n'
    'gb' 'git branch -vvv\n'
    'gL' 'gpull\n'
    'gP' 'git push\n'
    'gf' 'git fire\n'
    $'\egs' 'git status\n'
    $'\egS' './gstatus\n'
    $'\egd' 'git diff\n'
    $'\egl' 'git log\n'
    $'\egp' 'git log -p\n'
    $'\eg-' 'git checkout -\n'
    $'\eg\eg' 'magit\n'

    # Homebrew
    'bu' 'brew update && brew outdated\n'
    'bU' 'brew upgrade && brew cleanup\n'
    'bi' 'brew info '
    'be' 'brew edit '
    'bl' 'brew list --formula\n'
    'bs' 'brew search '
    'b/' 'brew list --formula | ag '

    # rvm
    'rl' 'rvm list\n'
    'rL' 'rvm list known\n'
    'r1' 'rvm use 1.8\n'
    'r2' 'rvm use 2.2\n'
    'r3' 'rvm use 2.3\n'
    'r4' 'rvm use 2.4\n'
    'r5' 'rvm use 2.5\n'
    'r6' 'rvm use 2.6\n'
    'rs' 'rvm use system\n'
    'rd' 'rvm use default\n'
    'ru' 'rvm get master\n'

    # spring gem
    'spl' 'spring status\n'
    'sps' 'spring rails runner 1\n'
    'spe' 'spring stop\n'

    # Maven / Mina
    'mdd' 'mina deploy '
    'mds' 'mina deploy stage=staging '
    'mdp' 'mina deploy stage=production '
    'mc' 'mvn compile\n'
    'mC' 'mvn clean\n'
    'mp' 'mvn package -Dmaven.test.skip=true\n'
    'msr' 'mvn spring-boot:run\n'
    'msj' 'mvn spring-boot:run -Dspring-boot.run.jvmArguments="-agentpath:/usr/local/jrebel/lib/libjrebel64.dylib"\n'
    'mr' 'mvn dependency:resolve\n'
    'mT' 'maven-deps-tree-to-org\n'
    'mt' 'mvn dependency:tree\n'
    'mi' 'mvn install\n'
    'mx' 'mvn exec:java -Dexec.mainClass= '

    # Install various packages
    'ib' 'brew install '
    'ig' 'gem install '
    'in' 'npm install '
    'ip' 'pip install --user '
    'ia' 'sudo apt-get install '
    'iy' 'sudo yum install '

    # Sys Admin
    'sL' "$([ $(uname) = Linux ] && echo 'sudo systemctl list-units | grep ' || echo 'brew services list\\n')"
    'sl' "$([ $(uname) = Linux ] && echo 'sudo systemctl status ' || echo 'brew services list | ag ')"
    'ss' "$([ $(uname) = Linux ] && echo 'sudo systemctl start ' || echo 'brew services start ')"
    'se' "$([ $(uname) = Linux ] && echo 'sudo systemctl stop ' || echo 'brew services stop ')"
    'sr' "$([ $(uname) = Linux ] && echo 'sudo systemctl restart ' || echo 'brew services restart ')"
    'pi' 'ping '
    'if' 'ifconfig '
    'ps' 'ps -ef | ag '
    'rc' 'rsync -az --progress _@_'
    'rC' 'rsync -az --progress --delete _@_'
    'tr' 'traceroute '
    'su' 'sudo _@_'
    'le' '_@_ | less '
    'ow' "chown -R $USER.$(groups|cut -d' ' -f1) _@_"
    'oW' 'chown -R root.root _@_'
    '+x' 'chmod +x _@_'
    'te' 'tree -NC\n'
    'mm' 'sudo PAGER=mitmproxy-viewer mitmproxy -m transparent --showhost -k -p 8888\n'
    'mM' 'PAGER=mitmproxy-viewer mitmproxy --showhost -k -p 8888\n'
    'tp' 'sudo toggle-pf all\n'
    'tP' 'sudo toggle-pf\n'
    'of' 'lsof -Pnp _@_'
    'vi' 'vim _@_\n'
    'pc' '_@_ | pc\n'
    'du' 'du -sh\n'
    'df' 'df -h\n'
    'rh' 'rehash\n'
    'tc' 'tar -zcf _@_.tgz _@_'
    'tx' 'tar -zxf _@_'

    # Trash
    'Tl' 'trash -l\n'
    'Te' 'trash -e\n'

    # Perl
    'sm' "_@_ | perl -lne '\$s+=\$_;END{print "\$s"}' "
    'pe' '_@_ || perl -e '
    'pp' '_@_ | perl -pe '
    'pn' '_@_ | perl -ne '
    'pa' '_@_ | perl -F"" -alne '

    # Ruby
    're' '_@_ || ruby -e '
    'rp' '_@_ | ruby -pe '
    'rn' '_@_ | ruby -ne '
    'ra' '_@_ | ruby -F"" -alne '

    # Files
    'ff' 'find . -name '
    'fF' 'mfd -o . '
    'f/' '_@_ || ag '
    'ag' '_@_ || ag '
    'fe' 'ee _@_\n'
    'fE' 'see _@_\n'
    'fx' 'x _@_\n'
    'fb' 'bat _@_\n'
    'fc' 'cat _@_ '
    'fh' '_@_ || head '
    'ic' '_@_ || iconv -f GBK '
    'fi' 'file _@_\n'
    'ft' 'tail -f _@_\n'
    'wl' '_@_ || wc -l '
    'wc' '_@_ || wc -c '
    'fo' 'open _@_\n'
    'f.' 'open .\n'
    'fp' 'preview _@_\n'
    'fD' '=rm -rf _@_ '
    'fd' 'trash _@_\n'
    'fR' 'mv _@_ '
    'fC' 'cp -a _@_ '
    'od' '_@_ || od -Ad -tc '
    'oD' '_@_ || od -Ad -tx1 '
    'fl' 'l -d _@_\n'
    'lv' 'lnav _@_'

    # Others
    'ty' 'type -a _@_ '
    $'\el' 'vrl\n'

    # Aliases in other layers
    'tk' 'tmux kill-server\n'
    'tl' 'tmux list-sessions\n'

    $'\x7f' 'echo saas\n'

    '?' 'spacezsh-help\n'
)

SPACEZSH_ALIAS_MAPPINGS[es]="emacs --daemon$([ $(uname) = Darwin ] && echo '=term')\\n"

function spacezsh.alias.widget() {
    local args=(${(z)BUFFER})
    local value=$SPACEZSH_ALIAS_MAPPINGS[$KEYS]
    if [[ "$value" =~ '_@_ *\|\|' ]]; then
      if [ -n "${BUFFER// /}" ]; then
        value=${value//||/|}
        value=${value//_@_/${${BUFFER% }# }}
      else
        value=${value#*||}
        value=${value#* }
      fi
    elif [[ "$value" =~ _@_ ]]; then
      value=${value//_@_/${${BUFFER% }# }}
    elif [[ "$KEYS" = $'\x7f' ]]; then
      value=${BUFFER%|*}
    else
        for i ({1..10}); do
            if [[ "$value" =~ _$i_ ]]; then
              value=${value//_$i_/$args[$i]}
            fi
        done
    fi

    BUFFER=''

    if [ "$value[-2,-1]" = '\n' ]; then
        LBUFFER=$value[1,-3]
        zle accept-line
    else
        LBUFFER=$value
    fi

    zle -K main
    zle redisplay
    typeset -f zle-line-init >/dev/null && zle zle-line-init
}

zle -N spacezsh.alias.widget

function spacezsh.alias.last_command.widget() {
  LBUFFER="$(history | tail -1 | perl -pe 's/^\s*\d*\s*//;s/\S+\s*$//')"
  zle -K main
  zle redisplay
  typeset -f zle-line-init >/dev/null && zle zle-line-init
}

zle -N spacezsh.alias.last_command.widget


function spacezsh.alias.last_command_name.widget() {
  LBUFFER="$(history | tail -1 | perl -pe 's/^\s*\d*\s*(\S+).*/$1 /')"
  zle -K main
  zle redisplay
  typeset -f zle-line-init >/dev/null && zle zle-line-init
}

zle -N spacezsh.alias.last_command_name.widget

bindkey "^x^p" spacezsh.alias.last_command.widget

bindkey "^xp" spacezsh.alias.last_command_name.widget

for k (${(k)SPACEZSH_ALIAS_MAPPINGS}); do
    if [[ "$k" =~ '^[a-zA-Z0-9/+?]' ]]; then
        bindkey -M SPACEZSH_KEYMAP "$k" spacezsh.alias.widget
    elif [[ "$k" = $'\x7f' ]]; then
          bindkey -M SPACEZSH_KEYMAP "$k" spacezsh.alias.widget
    else
        bindkey "$k" spacezsh.alias.widget
    fi
done
