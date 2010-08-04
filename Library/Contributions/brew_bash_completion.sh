# Bash completion script for brew(1)
#
# To use, edit your .bashrc and add:
#   source `brew --repository`/Library/Contributions/brew_bash_completion.sh

_brew_formulae_and_aliases()
{
    local ff=$(ls $(brew --repository)/Library/Formula | sed "s/\.rb//g")
    local af=$(ls $(brew --repository)/Library/Aliases 2> /dev/null | sed "s/\.rb//g")
    echo "${ff} ${af}"
}

_brew_to_completion()
{
    COMPREPLY=()
    local cur="${COMP_WORDS[COMP_CWORD]}"

    # Subcommand list
    [[ ${COMP_CWORD} -eq 1 ]] && {
        local actions="--cache --config --prefix cat cleanup configure create
            deps doctor edit home info install link list log outdated prune
            remove search unlink update uses"
        local ext=$(ls $(brew --repository)/Library/Contributions/examples |
                    sed -e "s/\.rb//g" -e "s/brew-//g")
        COMPREPLY=( $(compgen -W "${actions} ${ext}" -- ${cur}) )
        return 0
    }

    # Find the first non-switch word; this will be the command
    local prev_index=$((COMP_CWORD - 1))
    local prev="${COMP_WORDS[prev_index]}"
    while [[ $prev == -* ]]; do
        prev_index=$((--prev_index))
        prev="${COMP_WORDS[prev_index]}"
    done

    case "$prev" in
    # Commands that take a formula
    cat|deps|edit|fetch|home|homepage|info|log|options|uses)
        COMPREPLY=( $(compgen -W "$(_brew_formulae_and_aliases)" -- ${cur}) )
        ;;
    install)
        local switches="--interactive --git --use-llvm --ignore-dependencies --HEAD"
        local options=`brew options mysql | grep ^--`
        COMPREPLY=( $(compgen -W "${switches} ${options} $(_brew_formulae_and_aliases)" -- ${cur}) )
        ;;
    # Commands that take an existing brew
    abv|cleanup|link|list|ln|ls|remove|rm|uninstall|unlink)
        COMPREPLY=( $(compgen -W "$(ls $(brew --cellar))" -- ${cur}) )
        ;;
    # Other commands
    create)
        COMPREPLY=( $(compgen -W "--cache" -- ${cur}) )
        ;;
    esac
}

complete -o bashdefault -o default -F _brew_to_completion brew
