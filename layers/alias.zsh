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
    $'\eL' 'ls\n'
    $'\el\el' 'l\n'
    $'\elr' 'l -tr\n'
    $'\el\er' 'la -tr\n'
    $'\ela' 'la\n'

    # ssh-dialog
    $'\es' 'ss\n'

    # git
    'gs' 'git status\n'
    'gd' 'git diff\n'
    'gl' 'git log\n'
    'gp' 'git log -p\n'
    'g-' 'git checkout -\n'
    'gg' 'magit\n'
    'gr' 'git remote -vvv\n'
    'gb' 'git branch -vvv\n'
    'gL' 'git pull\n'
    'gP' 'git push\n'
    $'\egs' 'git status\n'
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
    'bl' 'brew list\n'
    'bs' 'brew search '
    'b/' 'brew list | ag '

    # rvm
    'rl' 'rvm list\n'
    'rL' 'rvm list known\n'
    'r1' 'rvm use 1.8\n'
    'r2' 'rvm use 2.2\n'
    'r3' 'rvm use 2.3\n'
    'r4' 'rvm use 2.4\n'
    'r5' 'rvm use 2.5\n'
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
    'mt' 'mvn dependency:tree | less\n'
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
    'ps' 'ps -ef | ag '
    'rc' 'rsync -az --progress --delete _@_ '
    'ns' 'nslookup '
    'tr' 'traceroute '
    'su' 'sudo _@_'
    'le' '_@_ | less '
    'ow' "chown -R $USER.$(groups|cut -d' ' -f1) _@_ "
    'oW' 'chown -R root.root _@_ '
    '+x' 'chmod +x _@_ '
    'te' 'tree -N\n'

    # Trash
    'Tl' 'mm -l\n'
    'Te' 'mm -e\n'

    # Perl
    'sm' "_@_ | perl -lne '\$s+=\$_;END{print "\$s"}' "
    'pe' '_@_ | perl -e '
    'pp' '_@_ | perl -pe '
    'pn' '_@_ | perl -ne '
    'pa' '_@_ | perl -F"" -alne '

    # Files
    'ff' 'find . -name '
    'fF' 'mfd -o . '
    'f/' '_@_ | ag '
    'fe' 'ee _@_\n'
    'fE' 'see _@_\n'
    'fb' 'bat _@_\n'
    'fc' 'cat _@_'
    'fh' '_@_ | head '
    'fi' '_@_ | iconv -f GBK '
    'ft' 'tail -f _@_\n'
    'wl' '_@_ | wc -l '
    'wc' '_@_ | wc -c '
    'fo' 'open _@_\n'
    'f.' 'open .\n'
    'fp' 'preview _@_\n'
    'fD' 'rm -r _@_ '
    'fT' 'mm _@_\n'
    'fR' 'mv _@_ '
    'fC' 'cp -a _@_ '
    'od' '_@_ | od -Ad -tc '
    'fl' 'l -d _@_\n'
    'lv' 'lnav _@_ '

    # Aliases in other layers
    'tk' 'tmux kill-server\n'
    'tl' 'tmux list-sessions\n'

    $'\x7f' 'echo saas\n'
)

SPACEZSH_ALIAS_MAPPINGS[es]="emacs --daemon$([ $(uname) = Darwin ] && echo '=term')\\n"

function spacezsh.alias.widget() {
    local args=(${(z)BUFFER})
    local value=$SPACEZSH_ALIAS_MAPPINGS[$KEYS]
    if [[ "$value" =~ _@_ ]]; then
      value=${value//_@_/$BUFFER}
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

for k (${(k)SPACEZSH_ALIAS_MAPPINGS}); do
    if [[ "$k" =~ '^[a-zA-Z0-9/]' ]]; then
        bindkey -M SPACEZSH_KEYMAP "$k" spacezsh.alias.widget
    elif [[ "$k" = $'\x7f' ]]; then
          bindkey -M SPACEZSH_KEYMAP "$k" spacezsh.alias.widget
    else
        bindkey "$k" spacezsh.alias.widget
    fi
done
