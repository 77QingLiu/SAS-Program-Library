cd /projects/<area>/stats/
/opt/subversion_server_1.7.7/bin/svn add formats
/opt/subversion_server_1.7.7/bin/svn add global
/opt/subversion_server_1.7.7/bin/svn add macros

/opt/subversion_server_1.7.7/bin/svn add --depth=empty dmc
/opt/subversion_server_1.7.7/bin/svn add dmc/prog
/opt/subversion_server_1.7.7/bin/svn add dmc/qcprog
/opt/subversion_server_1.7.7/bin/svn add dmc/*.sas
/opt/subversion_server_1.7.7/bin/svn add dmc/multirun_*

/opt/subversion_server_1.7.7/bin/svn add --depth=empty interim
/opt/subversion_server_1.7.7/bin/svn add interim/prog
/opt/subversion_server_1.7.7/bin/svn add interim/qcprog
/opt/subversion_server_1.7.7/bin/svn add interim/*.sas
/opt/subversion_server_1.7.7/bin/svn add interim/multirun_*

/opt/subversion_server_1.7.7/bin/svn add --depth=empty listings
/opt/subversion_server_1.7.7/bin/svn add listings/prog
/opt/subversion_server_1.7.7/bin/svn add listings/qcprog
/opt/subversion_server_1.7.7/bin/svn add listings/*.sas
/opt/subversion_server_1.7.7/bin/svn add listings/multirun_*

/opt/subversion_server_1.7.7/bin/svn add --depth=empty primary
/opt/subversion_server_1.7.7/bin/svn add primary/prog
/opt/subversion_server_1.7.7/bin/svn add primary/qcprog
/opt/subversion_server_1.7.7/bin/svn add primary/*.sas
/opt/subversion_server_1.7.7/bin/svn add primary/multirun_*

/opt/subversion_server_1.7.7/bin/svn add --depth=empty tabulate
/opt/subversion_server_1.7.7/bin/svn add tabulate/prog
/opt/subversion_server_1.7.7/bin/svn add tabulate/qcprog
/opt/subversion_server_1.7.7/bin/svn add tabulate/*.sas
/opt/subversion_server_1.7.7/bin/svn add tabulate/multirun_*

# All added folders ignore data outputs subfolder and all file types
/opt/subversion_server_1.7.7/bin/svn propset svn:ignore -R "data
outputs
*.log
*.lst
*.txt
*.zip
" .

# reset global to accept all file types
/opt/subversion_server_1.7.7/bin/svn propset svn:ignore -R "
*.pdf
*.xls
*.xlsx
" global

# reset root to igrnore deliverables
/opt/subversion_server_1.7.7/bin/svn propset svn:ignore "deliverables
*.xpt
*.log
*.lst
*.txt
*.zip
*.css
*.gif
*.png
*.emf
*.pdf
*.csv
*.xml
*.xls
*.xlsx
*.rtf
*.doc
*.docx" .

# Keyword properties for all SAS files
find . -name \*.sas | xargs svn propset svn:keywords 'LastChangedBy LastChangedDate Rev HeadURL' 

# commit all
/opt/subversion_server_1.7.7/bin/svn commit -m "Folder Setup, Inititial Revision (high-level folder structure)" . --depth immediates
/opt/subversion_server_1.7.7/bin/svn commit -m "Folder Setup, Inititial Revision (tabulate)" ./tabulate
/opt/subversion_server_1.7.7/bin/svn commit -m "Folder Setup, Inititial Revision (listings)" ./listings
/opt/subversion_server_1.7.7/bin/svn commit -m "Folder Setup, Inititial Revision (dmc)" ./dmc 
/opt/subversion_server_1.7.7/bin/svn commit -m "Folder Setup, Inititial Revision (interim)" ./interim
/opt/subversion_server_1.7.7/bin/svn commit -m "Folder Setup, Inititial Revision (primary)" ./primary
/opt/subversion_server_1.7.7/bin/svn commit -m "Folder Setup, Inititial Revision (other)" .

#Delete the script, to avoid accidental commits
rm -f "$0"
