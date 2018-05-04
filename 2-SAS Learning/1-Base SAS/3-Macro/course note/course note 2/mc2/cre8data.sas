/* Windows/UNIX */

/* STEP 1: Notice the default values for the %LET statements. */

/* STEP 2: If your files are not to be located in S:/workshop */
/* change the value of PATH= in the %LET statement to */
/* reflect your data location. */

/* STEP 3: Submit the program to create the course data files. */

/* STEP 4: View the Results and verify the CONTENTS procedure */
/* report lists the names of the SAS data sets that were created.*/


%let path=s:/workshop;

 /*+++++++++++++++++++++++++++++++++++++++++++++*/
/* Alternate Data Locations                     */
/* DO NOT CHANGE THE FOLLOWING CODE UNLESS     */
/* DIRECTED TO DO SO BY YOUR INSTRUCTOR.       */
 /*+++++++++++++++++++++++++++++++++++++++++++++*/


*%let path=s:/workshop/mc2;
*%let path=c:/workshop/mc2;
*%let path=c:/SAS_Education/mc2;
*%let path=c:/SAS_Education/lwmc2;


/*+++++++++++++++++++++++++++++++++++++++++++++*/
/* WARNING: DO NOT ALTER CODE BELOW THIS LINE */
/* UNLESS DIRECTED TO DO SO BY YOUR INSTURCTOR.*/
/*+++++++++++++++++++++++++++++++++++++++++++++*/

%include "&path/setup.sas";


/* Z/OS */

/*+++++++++++++++++++++++++++++++++++++++++*/
/* For Z/OS Comment out the three statements below.*/
/* Uncomment the following statements for Z/OS and */
/* follow the steps in comments above to set up */
/* the Z/OS data environment. */
/* Recommended SAS DATA library location: prefix.workshop.sasdata */
/* The setup process will use SASDATA as the third level */

*%let path=.workshop;

/*+++++++++++++++++++++++++++++++++++++++++++++*/
/* WARNING: DO NOT ALTER CODE BELOW THIS LINE */
/*++++++++++++++++++++++++++++++++++++++++++++*/

*%include "&path..sascode(setup)";
