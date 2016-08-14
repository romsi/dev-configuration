#!/bin/bash

# Install Homebrew

function install_homebrew
{
	/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" || return 1
}

# Install the latest ruby version

function install_ruby
{
	brew install ruby || return 1
}

# Install pod

function install_pod
{
	sudo gem install cocoapods || return 1
}

# Install ohmyzsh

function install_ohmyzsh
{
	sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)" || return 1
}

# Custom ohmyzsh

DEV_CONFIGURATION_PATH=/tmp/dev-configuration

function custom_ohmyzsh
{
	rm -rf $DEV_CONFIGURATION_PATH

	git clone https://github.com/romsi/dev-configuration.git $DEV_CONFIGURATION_PATH

	cp -r $DEV_CONFIGURATION_PATH/.zshrc ~/ || return 1
	cp -r $DEV_CONFIGURATION_PATH/.custom/themes  ~/.oh-my-zsh/custom/ || return 1
	cp .oh-my-zsh/custom/themes/agnoster-romsi.zsh-theme .oh-my-zsh/themes || return 1
}

# Install ZSH auto suggestions

ZSH_AUTOSUGGESTIONS_PATH=$ZSH_CUSTOM/plugins/zsh-autosuggestions

function install_zsh_autosuggestions
{
	rm -rf $ZSH_AUTOSUGGESTIONS_PATH
	git clone git://github.com/zsh-users/zsh-autosuggestions $ZSH_AUTOSUGGESTIONS_PATH || return 1
}

# Install ZSH syntax highlighting

function install_zsh_syntax_highlighting
{
	brew install zsh-syntax-highlighting || return 1
}

# Custom iTerm

function custom_iTerm
{
	cp $DEV_CONFIGURATION_PATH/iTerm/fonts/*.ttf /Library/Fonts/
	open -a iTerm $DEV_CONFIGURATION_PATH/iTerm/Solarized\ Dark.itermcolors || return 1
	echo "Now you should import the custom settings."
}

# Install Mobilette developer tool

DEV_TOOLS_PATH=/tmp/dev-tools

function install_developer_tools
{
	rm -rf $DEV_TOOLS_PATH 
	git clone https://github.com/Mobilette/Developer $DEV_TOOLS_PATH 
	cd $DEV_TOOLS_PATH
	bash $DEV_TOOLS_PATH/developer.sh new ios "Romain Asnar" "romain.asnar@gmail.com"
	cd -
}

# Check if a required tool is installed before running the installation

function validate
{
	open -Ra "${1}" > /dev/null 2>&1
	if [ $? -ne 0 ]; then
		return 1
	fi
	return 0
}

function error
{
	echo "${1}"
	return 1
}

function print_usage {
	echo "[ERROR] Usage: ./install.sh options type [parameters]"
	echo ""
	echo "  --all     		install all packages"
	echo "  --ohmyzsh 		install ohmyzsh package only"
	echo "  --development   install development package only"
	echo "  --help    get more information"
	echo ""
}

function install_development_option {
	install_homebrew
	install_ruby
	install_pod
	install_developer_tools
}

function install_ohmyzsh_option {
	install_homebrew
	install_ohmyzsh
	custom_ohmyzsh
	install_zsh_autosuggestions
	install_zsh_syntax_highlighting
	source ~/.zshrc
	custom_iTerm
}

case "${1}" in
    --help )
        echo "Help please."
        ;;
    --all )
		VALIDATED=true
		validate "Xcode" || error "You must install Xcode before running the installation." || VALIDATED=false
		validate "iTerm" || error "You must install iTerm before running the installation." || VALIDATED=false
		if [ $VALIDATED = false ]; then
			exit 1
		fi
		install_development_option
		install_ohmyzsh_option
		;;
	--ohmyzsh )
		validate "iTerm" || error "You must install iTerm before running the installation." || exit 1
		install_ohmyzsh_option
		;;
	--development )
		validate "Xcode" || error "You must install iTerm before running the installation." || exit 1
		install_development_option
		;;
    * )
		print_usage
		exit 1
		;;
esac