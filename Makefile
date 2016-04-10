all:
	[ -f ~/.vimrc ] || ln -s $(PWD)/vimrc ~/.vimrc
	[ -f ~/.zshrc ] || ln -s $(PWD)/zshrc ~/.zshrc
	[ -f ~/.tmux.conf ] || ln -s $(PWD)/tmux.conf ~/.tmux.conf

clean:
	[ -f ~/.vimrc ] || rm ~/.vimrc 
	[ -f ~/.zshrc ] || rm ~/.zshrc
	[ -f ~/.tmux.conf ] || rm ~/.tmux.conf

.PHONY: all
