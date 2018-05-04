/*-----------------------------------------------------------------------------
  PAREXEL INTERNATIONAL LTD

  Sponsor / Protocol No: Janssen Research & Development / 54767414MMY1005
  PXL Study Code:        222646

  SAS Version:           9.3
  Operating System:      UNIX
-------------------------------------------------------------------------------

  Author:                Qingjie Zeng $LastChangedBy: xiaz $
  Creation Date:         11Oct2014 / $LastChangedDate: 2017-07-26 03:18:49 -0400 (Wed, 26 Jul 2017) $

  Program Location/name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_JANSS234199_STATS/tabulate/qcprog/macros/jjqccmcoding.sas $

  Files Created:         cmcoding.log

  Program Purpose:       To deal coding in cm domain.

  Macro Parameters       NA

-------------------------------------------------------------------------------
MODIFICATION HISTORY:    Subversion $Rev: 2 $
-----------------------------------------------------------------------------*/

%MACRO jjqccmcoding (PRETXT_=);
length /* &PRETXT_._ATC2 $600 */ CMLVL1-CMLVL4  CMDECOD CMBASPRF CMTRDCD CMTRD $200. CMLVL1CD CMLVL2CD CMLVL3CD CMLVL4CD &PRETXT_._ATC_CODE_ $8.;
CODER_HIERARCHY_ = CODER_HIERARCHY;
  array CMLVL_(4,6) $200  CM1LVL1-CM1LVL6 CM2LVL1-CM2LVL6 CM3LVL1-CM3LVL6 CM4LVL1-CM4LVL6;
  array CMLVLCD_(4,6) $20  CM1LVLCD1-CM1LVLCD6 CM2LVLCD1-CM2LVLCD6 CM3LVLCD1-CM3LVLCD6 CM4LVLCD1-CM4LVLCD6;
  array CODER_HA (4) $1300 HIERARCHYA1-HIERARCHYA4;
  array CODER_HB (4) $1300 HIERARCHYB1-HIERARCHYB4;
  array CODER_H (4) $1300  HIERARCHY1-HIERARCHY4;
  do j = 1 to count(CODER_HIERARCHY_,"PRODUCT|");

    if index(CODER_HIERARCHY_,"PRODUCT|") then do;
      CODER_HA(j) = substr(CODER_HIERARCHY_,1,index(CODER_HIERARCHY_,"PRODUCT|")-1);
      CODER_HIERARCHY_=substr(CODER_HIERARCHY_,index(CODER_HIERARCHY_,"PRODUCT|"));
      if index(CODER_HIERARCHY_,"ATC|") then do;
      CODER_HB(j)  = substr(CODER_HIERARCHY_,1,index(CODER_HIERARCHY_,"ATC|")-1);
      CODER_HIERARCHY_=substr(CODER_HIERARCHY_,index(CODER_HIERARCHY_,"ATC|"));
      end;
      else do;
      CODER_HB(j)  = strip(CODER_HIERARCHY_);
      CODER_HIERARCHY_ = "";
      end;
    end;
    CODER_H (J) = catx(" ",CODER_HA(j),CODER_HB(j));

    do i = 1 to 6;
      if index(strip(scan(CODER_H(j),i,";")),"ATC|")  then do;
        CMLVL_(j,i) = scan(scan(CODER_H(j),i,";"),3,"|");
        CMLVLCD_(j,i) = scan(scan(CODER_H(j),i,";"),2,"|");
      end;
      else if index(strip(scan(CODER_H(j),i,";")),"PRODUCT|")  then do;
        CMLVL_(j,5) = strip(scan(scan(CODER_H(j),i,";"),3,"|"));
        CMLVLCD_(j,5) = scan(scan(CODER_H(j),i,";"),2,"|");
      end;
      else if index(strip(scan(CODER_H(j),i,";")),"PRODUCTSYNONYM|")  then do;
        CMLVL_(j,6) = strip(scan(scan(CODER_H(j),i,";"),3,"|"));
        CMLVLCD_(j,6) = scan(scan(CODER_H(j),i,";"),2,"|");
      end;

    end;
  end;

  call missing(CMDECOD,CMTRT_ATC,CMTRT_ATC_CODE,CMLVL4,CMLVL3,CMLVL2,CMLVL1,CMLVL4CD,CMLVL3CD,CMLVL2CD,CMLVL1CD);
    do k = 1 to 4;

      CMLVL1   = strip(CMLVL_(k,1));
      CMLVL1CD = strip(CMLVLCD_(k,1));
      CMLVL2   = strip(CMLVL_(k,2));
      CMLVL2CD = strip(CMLVLCD_(k,2));
      CMLVL3   = strip(CMLVL_(k,3));
      CMLVL3CD = strip(CMLVLCD_(k,3));
      CMLVL4   = strip(CMLVL_(k,4));
      CMLVL4CD = strip(CMLVLCD_(k,4));
	  CMDECOD  = strip(CMLVL_(k,5));
	  CMBASPRF =CMDECOD;
	  if not missing(CMLVLCD_(k,6)) then do;
	  CMTRDCD =CMLVLCD_(k,6);
	  CMTRD =CMLVL_(k,6);
	  end;
	  if missing(CMLVLCD_(k,6)) then do;
	  CMTRDCD =CMLVLCD_(k,5);
	  CMTRD =CMLVL_(k,5);
	  end;
      &PRETXT_._ATC2   = coalescec(CMLVL4,CMLVL3,CMLVL2,CMLVL1);
      &PRETXT_._ATC_CODE_ = coalescec(CMLVL4CD,CMLVL3CD,CMLVL2CD,CMLVL1CD);
      leave;
      end;
  %MEND;


