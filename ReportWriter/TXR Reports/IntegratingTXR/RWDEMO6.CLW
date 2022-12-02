! This program demonstrates how the TXR definition can be supplied dynamically
! to C%V%PRLB%X%

  PROGRAM

  MAP
  END

  INCLUDE('RWPRLIB.INC'),ONCE

NL EQUATE ('<13,10>')

TestReport STRING( |
'[REPORTS]'                                                             & NL & |
'Report1 REPORT,FONT(''Arial'',10),PRE(Report1),THOUS,AT(1000,1662,6500,8338)' & NL & |
'_REPORT_  BREAK'                                                       & NL & |
'_TOTALS_    BREAK'                                                     & NL & |
'Detail1       DETAIL,FONT(''Arial'',8,0),AT(0,0,,1031)'                & NL & |
'                STRING(@s20),USE(stu:FirstName),AT(51,0)'              & NL & |
'                STRING(@s20),USE(stu:LastName),AT(1565,0)'             & NL & |
'                STRING(@s12),USE(stu:Telephone),AT(3079,0)'            & NL & |
'              END'                                                     & NL & |
'            END'                                                       & NL & |
'          END'                                                         & NL & |
'          FOOTER,AT(1000,9000,,1000)'                                  & NL & |
'            STRING(@n5),PAGENO,AT(813,396,323)'                        & NL & |
'            STRING(''Page:''),AT(396,396)'                             & NL & |
'          END'                                                         & NL & |
'        END'                                                           & NL & |
'[FILES]'                                                               & NL & |
'students FILE,PRE(stu),DRIVER(''TOPSPEED''),NAME(''students.tps'')'    & NL & |
'KeyStudentNumber KEY(stu:Number),NOCASE,OPT'                           & NL & |
'MajorKey  KEY(stu:Major,stu:LastName,stu:FirstName),DUP,NOCASE,OPT'    & NL & |
'KeyLastName KEY(stu:LastName),DUP,NOCASE'                              & NL & |
'KeyGradYear KEY(-stu:GradYear,stu:LastName,stu:FirstName),DUP,NOCASE,OPT' & NL & |
'Photo     MEMO(64000),BINARY'                                          & NL & |
'__Record  RECORD'                                                      & NL & |
'Number      LONG'                                                      & NL & |
'FirstName   STRING(20)'                                                & NL & |
'LastName    STRING(20)'                                                & NL & |
'Address     STRING(20)'                                                & NL & |
'Address2    STRING(20)'                                                & NL & |
'City        STRING(20)'                                                & NL & |
'State       STRING(2)'                                                 & NL & |
'Zip         LONG'                                                      & NL & |
'Telephone   STRING(12)'                                                & NL & |
'Major       LONG'                                                      & NL & |
'GradYear    LONG'                                                      & NL & |
'          END'                                                         & NL & |
'        END'                                                           & NL & |
                                                                          NL & |
'[REPORTVIEWS]'                                                         & NL & |
'Report1 VIEW(students),ORDER(''UPPER(stu:LastName)''),KEY(stu:KeyLastName)' & NL & |
'        END'                                                           & NL )


RE CLASS(ReportEngine)
ReadReportLibrary   PROCEDURE(*CSTRING buffer,USHORT count),SHORT,DERIVED
Pos                 SHORT
   END

  CODE
    RE.Pos = 0
    RE.LoadReportLibrary('')
    RE.SetPreview()
    RE.SetNextPageNumber(10)
    RE.PrintReport('Report1')
    RE.UnloadReportLibrary

RE.ReadReportLibrary   PROCEDURE (*CSTRING buffer,USHORT count)
! return report definition
l USHORT
i SHORT
  CODE
    l = SIZE(TestReport)-SELF.Pos
    IF l>count THEN l=count.
    LOOP i = 1 TO l
      SELF.Pos += 1
      buffer[i] = TestReport[SELF.Pos]
    END
    RETURN l






