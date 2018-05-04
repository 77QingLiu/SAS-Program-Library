. /etc/bashrc
export PS1='$PWD . '
PATH=$PATH:/home/users/linjo/shellscripts
alias svn=/opt/subversion_server_1.7.7/bin/svn
alias svnRevision='/opt/subversion_server_1.7.7/bin/svn info -r "HEAD" | grep Revision'
alias svnKeywords='/opt/subversion_server_1.7.7/bin/svn propset svn:keywords "Date Author Revision URL"'
